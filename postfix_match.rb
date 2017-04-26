module PostfixMatch
  TIME_AND_PID= /(?<startTime>[\w]+\s+[\d]+\s[\d:]+)\s+(?<agentHostName>[\w]+)\s+(?<process_name>[\w\/]+)\[(?<pid_id>[\d]+)\]\:/
  TO= /#{TIME_AND_PID}\s(?<agentId>[\w]{11,14}):\sto=(?<destinationAddress>[^,]+),\s(orig_to=(?<destinationUserName>[^,]+),)?\srelay=(?<relay>[^,]+),\sdelay=(?<delay>[^,]+),\sdelays=(?<delays>[^,]+),\sdsn=(?<dns>[^,]+),\sstatus=(?<status>[\w]+)\s\((?<message>(.*))\)/
  TO_ORIG= /#{TIME_AND_PID}\s(?<agentId>[\w]{11,14}):\sto=(?<destinationAddress>[^,]+),\srelay=(?<destinationHostName>[^,]+),\sdelay=(?<delay>[^,]+),\sdelays=(?<delays>[^,]+),\sdsn=(?<dns>[^,]+),\sstatus=(?<status>[\w]+)\s\((?<message>(.*))\)/
  FROM= /#{TIME_AND_PID}\s(?<agentId>[\w]{11,14}):\sfrom=(?<sourceAddress>[^,]+),\ssize=(?<fileSize>[^,]+),\snrcpt=(?<nrcpt>[\w]+)\s\((?<message>(.*))\)/
  MESSAGE_ID= /#{TIME_AND_PID}\s(?<agentId>[\w]{11,14}):\smessage-id=(?<eventId>.+)/
  OTHER= /#{TIME_AND_PID}\s(?<agentId>[\w]{11,14}):\s(?<data>.+)/

  REMOVED= /#{TIME_AND_PID}\s(?<agentId>[\w]{11,14}):\sremoved/
  CONNECT= /#{TIME_AND_PID}\s:\sconnect from (?<data>.+)/
  DISCONNECT= /#{TIME_AND_PID}\s:\sdisconnect from (?<data>.+)/

  REG_EXPS = [TO,TO_ORIG,FROM,OTHER]
  TO_SKIP = [REMOVED,CONNECT,DISCONNECT]
end