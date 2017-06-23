module PostfixMatch
  TIME_AND_PID= /(?<event_time>[\w]+\s+[\d]+\s[\d:]+)\s+(?<host_name>[\w]+)\s+(?<process_name>[\w\/]+)\[(?<pid>[\d]+)\]\:/
  TO= /#{TIME_AND_PID}\s(?<event_id>[\w]{11,14}):\sto=<(?<mail_to>[^,]+)>,\s(orig_to=<(?<mail_orig_to>[^,]+)>,)?\srelay=(?<relay_host>[^,]+),\sdelay=(?<delay>[^,]+),\sdelays=(?<delays>[^,]+),\sdsn=(?<dns>[^,]+),\sstatus=(?<status>[\w]+)\s\((?<data>(.*))\)/
  TO_ORIG= /#{TIME_AND_PID}\s(?<event_id>[\w]{11,14}):\sto=<(?<mail_to>[^,]+)>,\srelay=(?<relay_host>[^,]+),\sdelay=(?<delay>[^,]+),\sdelays=(?<delays>[^,]+),\sdsn=(?<dns>[^,]+),\sstatus=(?<status>[\w]+)\s\((?<data>(.*))\)/
  FROM= /#{TIME_AND_PID}\s(?<event_id>[\w]{11,14}):\sfrom=<(?<sender>[^,]+)>,\ssize=(?<mail_size>[^,]+),\snrcpt=(?<nrcpt>[\w]+)\s\((?<data>(.*))\)/
  MESSAGE_ID= /#{TIME_AND_PID}\s(?<event_id>[\w]{11,14}):\smessage-id=<(?<mail_message_id>.+)>/
  CONNECTION= /#{TIME_AND_PID}\s(?<event_id>[\w]{11,14}):\sclient=(?<orig_ip>.+)/
  OTHER= /#{TIME_AND_PID}\s(?<event_id>[\w]{11,14}):\s(?<data>.+)/

  REMOVED= /#{TIME_AND_PID}\s(?<event_id>[\w]{11,14}):\sremoved/
  CONNECT= /#{TIME_AND_PID}\sconnect from (?<data>.+)/
  DISCONNECT= /#{TIME_AND_PID}\sdisconnect from (?<data>.+)/
  SSL= /#{TIME_AND_PID}\s(?<ssl_error_desc>SSL_accept\serror)\sfrom\s(?<ssl_error_host>.+)\[(?<ssl_error_ip>.+)\]/

  REG_EXPS = [MESSAGE_ID,TO,TO_ORIG,FROM,CONNECTION,SSL,OTHER]
  TO_SKIP = [REMOVED,CONNECT,DISCONNECT]
end
