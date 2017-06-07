require 'rubygems'
require 'cef'
require 'getoptlong'
require "file-tail"
require_relative "./postfix_match.rb"
require_relative "./mailbox_match.rb"

@verbose=0
@file=nil
SEVERITY = {"NOTICE" => "0", "INFO" => "1", "WARNING" => "2", "ERROR" => "3" }
cef_event=CEF::Event.new
opts=GetoptLong.new(
    ["--verbose",       GetoptLong::OPTIONAL_ARGUMENT],
    ["--help",          GetoptLong::OPTIONAL_ARGUMENT],
    ["--schema",        GetoptLong::OPTIONAL_ARGUMENT],
    ["--receiver",      GetoptLong::OPTIONAL_ARGUMENT],
    ["--receiverPort",  GetoptLong::OPTIONAL_ARGUMENT],
    ["--input-file",    GetoptLong::OPTIONAL_ARGUMENT],
    ["--map",           GetoptLong::OPTIONAL_ARGUMENT],
    ["--unprocessed",   GetoptLong::OPTIONAL_ARGUMENT],
    #["--deviceVendor",   GetoptLong::OPTIONAL_ARGUMENT],
    #["--deviceProduct",   GetoptLong::OPTIONAL_ARGUMENT],
    *cef_event.attrs.keys.collect {|o| ["--#{o}", GetoptLong::OPTIONAL_ARGUMENT]}
)


def print_usage
  puts <<END_USAGE
Usage: zimbra_to_cef --sourceAddress="192.168.1.1" [--schema_field=new_field]

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

  match_data.names.each do |_field|
    value = match_data[_field]
    field = @maps.has_key?(_field.to_s) ?  @maps[_field] : _field.to_s
    case field
      when /event_time/i
        value = DateTime.parse(value)
      when /severity/i
        value = SEVERITY[value.upcase] || 5
    end

    puts "#{field}: #{value}" if @verbose > 1
    method_name =  "#{field}=".to_sym
    if cef_event.respond_to?(method_name)
      cef_event.send( method_name, value)

    else
      cef_event.set_additional( field, value)

    end
  end
end


def mailbox_to_cef(line)
  MailboxMatch::REG_EXPS.each do |reg_exp|
    puts "testing #{reg_exp}" if @verbose > 2
    a = line.match(reg_exp)
    if a
      cef_event=CEF::Event.new(deviceVendor: @deviceVendor, deviceProduct: @deviceProduct,
                               deviceEventClassId: "0:event", name: "mailbox event")
      match_to_event(a, cef_event)
      #cef_sender.emit(cef_event) if cef_sender
      #puts cef_event.to_s if  @verbose > 0
      return cef_event
    end
  end
  return nil
end

def postfix_to_cef(line)
  PostfixMatch::TO_SKIP.each do |reg_exp|
    puts "testing skipping #{reg_exp}" if @verbose > 2
    a = line.match(reg_exp)
    return true  if a
  end
  PostfixMatch::REG_EXPS.each do |reg_exp|
    puts "testing #{reg_exp}" if @verbose > 2
    a = line.match(reg_exp)
    if a
      cef_event=CEF::Event.new(deviceVendor: @deviceVendor, deviceProduct: @deviceProduct, deviceEventClassId: "0:event", name: "postfix event")

      match_to_event(a, cef_event)
      #cef_sender.emit(cef_event) if cef_sender
      #puts cef_event.to_s if (cef_sender.nil? || @verbose > 0)
      return cef_event
    end
  end
  return nil
end

@maps = {}
@show_unprocessed = false

opts.each do |opt,arg|
  # TODO: set up cases for startTime, receiptTime, endTime to parse
  #       text and convert to unix time * 1000
  case opt
    when "--unprocessed"
      @show_unprocessed = true
    when "--deviceVendor"
      @deviceVendor = arg
    when "--deviceProduct"
      @deviceProduct = arg
    when "--verbose"
      @verbose+=1
    when "--schema"
      cef_event = CEF::Event.new
      print_schema(cef_event)
      puts "POSTFIX REGEXP"
      PostfixMatch::REG_EXPS.each do |x|
        puts  x
      end
      puts "MAILBOX REGEXP"
      MailboxMatch::REG_EXPS.each do |x|
        puts x
      end
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
    when "--attribute_map_file"
      @map_file=File.open(arg)
    when "--map"
      arg.split(",").each do |_value|
        value=_value.split(":")
        @maps[value.first] = value.last
      end
  end
end

@deviceVendor       ||= "breed.org"
@deviceProduct      ||= "CEF"
@deviceVersion      = CEF::VERSION
@deviceEventClassId ||= "0:event"
@deviceSeverity     = CEF::SEVERITY_LOW
@name               ||= "unnamed event"

#exit(0) if @file.nil?


  if @receiver_host
    cef_sender=CEF::UDPSender.new(@receiver_host,@receiver_port)
  end
  if @file
      @file.extend(File::Tail)
      @file.interval # 10
      #@file.backward(100)
      @file.tail do |line|
          cef_event = nil
          cef_event ||= postfix_to_cef(line)
          cef_event ||=  mailbox_to_cef(line)
          cef_sender.emit(cef_event) if cef_sender && cef_event.is_a?(CEF::Event)
          puts cef_event.to_s if (cef_sender.nil? || @verbose > 0)
          puts line if (cef_event.nil? && @show_unprocessed )
      end
  else
      while STDIN.gets
        line = $_.chomp
        cef_event = nil
        cef_event ||= postfix_to_cef(line)
        cef_event ||=  mailbox_to_cef(line)
        cef_sender.emit(cef_event) if cef_sender && cef_event.is_a?(CEF::Event)
        puts cef_event.to_s if (cef_sender.nil? || @verbose > 0)
        puts line if (cef_event.nil? && @show_unprocessed )
      end
  end

