Received: from exch-staff1.ul.ie ([136.201.1.64])
 by ul.ie (PMDF V5.2-32 #41949) with ESMTP id <0GJZ00J1J726OJ@ul.ie> for
 linux-mm@kvack.org; Thu, 20 Sep 2001 20:20:30 +0100 (BST)
Content-return: allowed
Date: Thu, 20 Sep 2001 20:25:37 +0100
From: "Gabriel.Leen" <Gabriel.Leen@ul.ie>
Subject: Process not given >890MB on a 4MB machine ?????????
Message-id: <5D2F375D116BD111844C00609763076E050D164D@exch-staff1.ul.ie>
MIME-version: 1.0
Content-type: text/plain
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello,
The problem in a nutshell is:

a) I have a 4GB ram 1.7Gh Xeon box
b) I'm running a process which requires around 3GB of ram
c) RedHat 2.4.9 will only give it 890MB, then core dumps with the warning
"segmentation fault"
when it reaches this memory usage and "asks for more"

+++++++++++++++++
Details:

System/OS:
I'm running RedHat 2.4.9, with the 4GB memory support selected 
and the latest patch from
www.kernel.org/pub/linux/kernel/people/alan/linux-2.4/2.4.9 
4GB RAM, slightly less seen by system, (Top, XOSVIEW, etc)
Running as root with the bash shell ulimit command returning: "unlimited"


When it crashes:
according to top): for the process: SIZE 893 MB ,RSS 893 MB, 
"segmentation fault" (core dumped)

+++++++++++++++++
Other Info:

I don't know if the problem has something to do with PAGE_OFFSET in page.h
it is currently set at C0000000
I tried changing this but the machine would not boot then.

I can run 2 or 3 processes using 1 GB at a time but one process using >1GB
is not possible ??

+++++++++++++++++

Any suggestions / advice is very much appreciated, Thanx in advance,

Gabriel

*********************************************************************
Gabriel Leen                        Tel:        00353  61  20 2677
PEI  Technologies               Fax:       00353  61  33 4925
Foundation Building             E-mail:   gabriel.leen@ul.ie
University of Limerick
Limerick
Ireland
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
