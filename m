Message-ID: <20040129143822.49204.qmail@web40702.mail.yahoo.com>
Date: Thu, 29 Jan 2004 06:38:22 -0800 (PST)
From: sandeep chavan <sandy_pict@yahoo.com>
Subject: How to access remote proc file system?
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 Hi all. I am an enggineering student working on a 
project distributed systems monitoring and management.
 I want to ask u that how can i access /proc files
from
 remote machine? suppose i want to watch /proc/cpuinfo
of machine A from macine B. Then how can i do it?
Using this i want to monitor and manage the network
from a central location eliminating the need for me
(i.e.administrator) to login at each client machine to
see it's status. Storing the result in buffer and then
sending it is one way as i can see. but the work will
become tedious. Another way suggested to me is to use
SSH. Setup password-less authentication for SSH and
then 
acces /proc of the other machines. 


__________________________________
Do you Yahoo!?
Yahoo! SiteBuilder - Free web site building tool. Try it!
http://webhosting.yahoo.com/ps/sb/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
