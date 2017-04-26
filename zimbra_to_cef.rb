require 'rubygems'
require 'cef'
require 'getoptlong'
require "file-tail"
require_relative "./postfix_match.rb"
require_relative "./mailbox_match.rb"

@verbose=0
@file=nil
opts=GetoptLong.new(
    ["--verbose",       GetoptLong::OPTIONAL_ARGUMENT],
    ["--help",          GetoptLong::OPTIONAL_ARGUMENT],
    ["--schema",        GetoptLong::OPTIONAL_ARGUMENT],
    ["--receiver",      GetoptLong::OPTIONAL_ARGUMENT],
    ["--receiverPort",  GetoptLong::OPTIONAL_ARGUMENT],
    ["--input-file",   GetoptLong::OPTIONAL_ARGUMENT],
    ["--deviceVendor",   GetoptLong::OPTIONAL_ARGUMENT],
    ["--deviceProduct",   GetoptLong::OPTIONAL_ARGUMENT],

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
     --deviceVendor
     --deviceProduct
     

cef_sender will send CEF-formatted syslog messages to a receiver of your choice.


END_USAGE

end

def print_schema(event)
  event.attrs.keys.collect {|k| k.to_s}.sort.each {|a| puts a}
end

def match_to_event(match_data, cef_event)
  match_data.names.each do |field|
    value = a[field]
    value = DateTime.parse(value) if field == "eventTime"
    puts "#{field}: #{value}" if @verbose > 1
    method_name =  "#{field}=".to_sym
    cef_event.send( method_name, value) if cef_event.respond_to?(method_name)
  end
end


@verbose = 0
opts.each do |opt,arg|
  # TODO: set up cases for startTime, receiptTime, endTime to parse
  #       text and convert to unix time * 1000
  case opt
    when "--deviceVendor"
      @deviceVendor = arg
    when "--deviceProduct"
      @deviceProduct = arg
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
    #else
    #  fieldname = opt.gsub(/-/,'')
    #  value=arg
    #  cef_event.send("%s=" % fieldname, value)
  end
end

@deviceVendor       ||= "breed.org"
@deviceProduct      ||= "CEF"
@deviceVersion      = CEF::VERSION
@deviceEventClassId ||= "0:event"
@deviceSeverity     = CEF::SEVERITY_LOW
@name               ||= "unnamed event"

exit(0) if @file.nil?

if @receiver_host
  cef_sender=CEF::UDPSender.new
  cef_sender.receiver=@receiver_host
  cef_sender.receiverPort=@receiver_port
end
  @file.extend(File::Tail)
  @file.interval # 10
  @file.backward(100)
  @file.tail do |line|


      cef_event = nil
      PostfixMatch::TO_SKIP.each do |reg_exp|
        puts "testing skipping #{reg_exp}" if @verbose > 2
        a = line.match(reg_exp)
        if a
          cef_event = true
          break
        end
      end
      unless cef_event # skip if skipped!
        PostfixMatch::REG_EXPS.each do |reg_exp|
          puts "testing #{reg_exp}" if @verbose > 2
          a = line.match(reg_exp)
          if a
            cef_event=CEF::Event.new(deviceVendor: @deviceVendor, deviceProduct: @deviceProduct, deviceEventClassId: "0:event", name: "postfix event")
            match_to_event(a, cef_event)
            cef_sender.emit(cef_event) if cef_sender
            puts cef_event.to_s unless cef_sender
            break
          end
        end
        #break if cef_event # skip if found on postfix!
        MailboxMatch::REG_EXPS.each do |reg_exp|
          puts "testing #{reg_exp}" if @verbose > 2
          a = line.match(reg_exp)
          if a
            cef_event=CEF::Event.new(deviceVendor: @deviceVendor, deviceProduct: @deviceProduct,
                                     deviceEventClassId: "0:event", name: "mailbox event")
            match_to_event(a, cef_event)
            cef_sender.emit(cef_event) if cef_sender
            puts cef_event.to_s unless cef_sender
            break
          end
        end
      end
      puts line if (cef_event.nil? && @verbose > 0)
  end


