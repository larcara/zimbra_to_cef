require 'rubygems'
require 'cef'
require 'getoptlong'
require "file-tail"

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

cef_sender=CEF::UDPSender.new
cef_sender.receiver=@receiver_host
cef_sender.receiverPort=@receiver_port



#File.open(filename) do |log|
  @file.extend(File::Tail)
  @file.interval # 10
  @file.backward(10)
  @file.tail do |line|
    if line.match("postfix/(.*)\[(.*)]: ([0-9A-Z]{12,14})")
      cef_event=CEF::Event.new
      cef_event.attrs[:deviceCustomString1] = line
      cef_sender.emit(cef_event)
    end
  end
#end
