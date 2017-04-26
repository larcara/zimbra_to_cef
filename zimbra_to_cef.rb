require 'rubygems'
require 'cef'
require 'getoptlong'
require "file-tail"
require_relative "./postfix_match.rb"

@verbose=0
@file=nil
opts=GetoptLong.new(
    ["--verbose",       GetoptLong::OPTIONAL_ARGUMENT],
    ["--help",          GetoptLong::OPTIONAL_ARGUMENT],
    ["--schema",        GetoptLong::OPTIONAL_ARGUMENT],
    ["--receiver",      GetoptLong::OPTIONAL_ARGUMENT],
    ["--receiverPort",  GetoptLong::OPTIONAL_ARGUMENT],
    ["--input-file",   GetoptLong::OPTIONAL_ARGUMENT],
)


def print_usage
  puts <<END_USAGE
Usage: zimbra_to_cef --sourceAddress="192.168.1.1" [--eventAttribute="something"]

  non-schema arguments: 
     --help gets you here
     --schema will dump all of the callable event attribute names
     --receiver= syslog receiver hostname/ip
     --receiverPort= syslog port
     --input-file=  filename to input messagge cef message to
     

cef_sender will send CEF-formatted syslog messages to a receiver of your choice.


END_USAGE

end

def print_schema(event)
  event.attrs.keys.collect {|k| k.to_s}.sort.each {|a| puts a}
end

@verbose = 0
opts.each do |opt,arg|
  # TODO: set up cases for startTime, receiptTime, endTime to parse
  #       text and convert to unix time * 1000
  case opt
    when "--verbose"
      @verbose+=1
    when "--schema"
      cef_event = CEF::Event.new
      print_schema(cef_event)
      exit(0)
    when "--receiverPort"
      @receiver_port=arg
    when "--receiver"
      @receiver_host=arg
    when "--help"
      print_usage
      exit(0)
    when "--input-file"
      @file=File.open(arg)
    else
      fieldname = opt.gsub(/-/,'')
      value=arg
      cef_event.send("%s=" % fieldname, value)
  end
end


exit(0) if @file.nil?

if @receiver_host
  cef_sender=CEF::UDPSender.new
  cef_sender.receiver=@receiver_host
  cef_sender.receiverPort=@receiver_port
end
#REGEXP
time_and_pid= /(?<time>[\w]+\s+[\d]+\s[\d:]+)\s+(?<host>[\w]+)\s+(?<process>[\w\/]+)\[(?<pid>[\d]+)\]\:/
format1= /#{time_and_pid}\s(?<queue_id>[\w]{11,14}):\s(?<data>.+)/
format2= /#{time_and_pid}\s(?<queue_id>[\w]{11,14}):\sfrom=(?<from_address>[^,]+),\ssize=(?<size>[^,]+),\snrcpt=(?<nrcpt>[\w]+)\s\((?<message>(.*))\)/
format3= /#{time_and_pid}\s(?<queue_id>[\w]{11,14}):\sto=(?<to_address>[^,]+),\sorig_to=(?<orig_to_address>[^,]+),\srelay=(?<relay>[^,]+),\sdelay=(?<delay>[^,]+),\sdelays=(?<delays>[^,]+),\sdsn=(?<dns>[^,]+),\sstatus=(?<status>[\w]+)\s\((?<message>(.*))\)/


#File.open(filename) do |log|
  @file.extend(File::Tail)
  @file.interval # 10
  @file.backward(10)
  @file.tail do |line|
      cef_event = nil
      PostfixMatch::TO_SKIP.each do |reg_exp|
        puts "testing skipping #{reg_exp}" if @verbose > 1
        a = line.match(reg_exp)
        if a
          cef_event = true
          break
        end
      end
      break if cef_event # skip if skipped!
      PostfixMatch::REG_EXPS.each do |reg_exp|
        puts "testing #{reg_exp}" if @verbose > 1
        a = line.match(reg_exp)
        if a
          cef_event=CEF::Event.new
          a.names.each do |field|
            puts "#{field}: #{a[field]}" if @verbose > 1
            cef_event.attrs[field] = a[field]
          end
          cef_sender.emit(cef_event) if cef_sender
          break
        end
      end
      puts line if cef_event.nil? if @verbose > 0
  end
#end
