module MailboxMatch




  TIME_AND_PID= /(?<startTime>[\w]+\s+[\d]+\s[\d:]+)\s+(?<agentHostName>[\w]+)\s+(?<process_name>[\w\/]+)\:\s(?<deviceSeverity>[\w]+)/
  LMTP_DELIVERING = /(?<event_time>[\w]+\s+[\d]+\s[\d:]+)\s+(?<host_name>[\w]+)\s+(?<process_name>[\w\/]+)\:\s(?<severity>[\w]+)\s+\[(?<process>[\w]+-[\d]+)\]\s\[.*\]\slmtp - Delivering message:\ssize=(?<size>[\d]+)\sbytes, nrcpts=[\d]+,\ssender=(?<sender>[\S]+@[\S]+),\smsgid=(?<mail_message_id>[\S]+)/
  MAILBOX_ADDING =  /(?<event_time>[\w]+\s+[\d]+\s[\d:]+)\s+(?<host_name>[\w]+)\s+(?<process_name>[\w\/]+)\:\s(?<severity>[\w]+)\s+\[(?<process>[\w|\d]+)-[\d]+(:\/\/.*\/service\/soap\/(?<soap_action>[\S]+))?\]\s\[.*\]\smailop - Adding Message:\sid=(?<zimbra_message_id>[\d]+),\sMessage-ID=(?<mail_message_id>[\S]+),\sparentId=(?<parent_id>[-|\d]+),\sfolderId=(?<folder_id>[\d]+),\sfolderName=(?<folder_name>[\w]+)./
  SENDIG_TO_MTA = /(?<event_time>[\w]+\s+[\d]+\s[\d:]+)\s+(?<host_name>[\w]+)\s+(?<process_name>[\w\/]+)\:\s(?<severity>[\w]+)\s+\[(?<process>[\w|\d]+)-[\d]+(:\/\/.*\/service\/soap\/(?<soap_action>[\S]+))?\]\s\[.*\]\ssmtp - Sending message to MTA at localhost:\sMessage-ID=(?<mail_message_id>[\S]+),\sreplyType=(?<reply_type>[\S]+)/


  REG_EXPS = [LMTP_DELIVERING,MAILBOX_ADDING,SENDIG_TO_MTA]
  TO_SKIP = []

end