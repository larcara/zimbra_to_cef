Usage

1. create a socket


    mkfifo /tmp/mailboxlog.sock
    
2. send  remote tail to the socket


    ssh -C -a user@zimbraserver.local "tail -F /opt/zimbra/log/mailbox.log" >> /tmp/mailboxlog.sock
       
3. start ruby_to_cef


    bundle exec ruby zimbra_to_cef.rb --input-file=/tmp/mailboxlog.sock --receiver="CEF_SERVER" --receiverPort=1516 --verbose --deviceVendor=zimbra --deviceProduct=zimbraVersion --map="host_name:shn,process_name:rv60,severity:sev,process:obssvcname,soap_action:isvcc,zimbra_message_id:s_AppId,mail_message_id:deviceExternalId,folder_name:cv21"
    
    
    