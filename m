Received: from [129.179.161.11] by ns1.cdc.com with ESMTP for linux-mm@kvack.org; Mon, 27 Aug 2001 15:17:40 -0500
Received: from [129.179.80.32] by cdsms.cdc.com with ESMTP for linux-mm@kvack.org; Mon, 27 Aug 2001 15:17:38 -0500
Message-Id: <3B8AAA3E.80707@syntegra.com>
Date: Mon, 27 Aug 2001 15:14:54 -0500
From: Andrew Kay <Andrew.J.Kay@syntegra.com>
Subject: kernel: __alloc_pages: 1-order allocation failed
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I am having some rather serious problems with the memory management (i 
think) in the 2.4.x kernels.  I am currently on the 2.4.9 and get lots 
of these errors in /var/log/messages.

Aug 24 15:08:04 dell63 kernel: __alloc_pages: 1-order allocation failed.
Aug 24 15:08:35 dell63 last message repeated 448 times
Aug 24 15:09:37 dell63 last message repeated 816 times
Aug 24 15:10:38 dell63 last message repeated 1147 times

I am running a Redhat 7.1 distro w/2.4.9 kernel on a Dell poweredge 6300 
(4x500Mhz cpu, 4Gb ram).  I get this error while running the specmail 
2001 benchmarking software against our email server, Intrastore.  The 
system  is very idle from what I can see.  The sar output shows user cpu 
at around 1% and everything else rather low as well.  It seems to pop up 
randomly and requires a reboot to fix it.

Is there any workarounds or something I can do to get a more useful 
debug message than this?  It doesn't seem to throw any other visible 
errors.  Maybe an older more stable kernel or less memory?  I have the 
sar output if anyone is interested.  This bug is the only current 
roadblock for me to publish specmail 2001 results to spec.org.  It can 
be reproduced fairly easily with a little setup time.

Thanks,
Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
