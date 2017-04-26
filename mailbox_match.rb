module MailboxMatch


  TIME_AND_PID= /(?<event_time>[\w]+\s+[\d]+\s[\d:]+)\s+(?<agentHostName>[\w]+)\s+(?<process_name>[\w\/]+)\:\s(?<deviceSeverity>[\w]+)/
  LMTP_DELIVERING = /(?<event_time>[\w]+\s+[\d]+\s[\d:]+)\s+(?<agentHostName>[\w]+)\s+(?<process_name>[\w\/]+)\:\s(?<deviceSeverity>[\w]+\s+\[(?<process>[\w]+-[\d]+)\])\s\[.*\]\slmtp - Delivering message:\ssize=(?<size>[\d]+)\sbytes, nrcpts=[\d]+,\ssender=(?<sender>[\S]+@[\S]+),\smsgid=(?<eventID>[\S]+)/
  MAILBOX_ADDING = /(?<event_time>[\w]+\s+[\d]+\s[\d:]+)\s+(?<agentHostName>[\w]+)\s+(?<process_name>[\w\/]+)\:\s(?<deviceSeverity>[\w]+\s+\[(?<process>[\w]+-[\d]+)\])\s\[.*\]\smailop - Adding Message:\sid=(?<message_id>[\d]+),\sMessage-ID=(?<eventID>[\S]+),\sparentId=(?<folder_id>[\d]+),\sfolderId=(?<folder_id>[\d]+),\sfolderName=(?<folder_name>[\w]+)./



  REG_EXPS = [LMTP_DELIVERING,MAILBOX_ADDING]
  TO_SKIP = []

end