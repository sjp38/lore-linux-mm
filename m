Received: from rttsdev.vsnl.in (PPP-200-6-155.bng.vsnl.net.in [203.200.6.155])
	by blr.vsnl.net.in (Postfix) with SMTP id C8D2F77C4
	for <linux-mm@kvack.org>; Thu, 14 Mar 2002 10:46:23 +0530 (IST)
From: "anand" <anand@rttsindia.com>
Reply-To: anand@rttsindia.com
Subject: Reducing the size of malloc memory!
Date: Thu, 14 Mar 2002 10:39:14 +0530
Content-Type: text/plain
MIME-Version: 1.0
Message-Id: <02031410405300.01565@linuxserver>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, 
        I have a question regarding memory management. I would like to know whether I can change the amount of memory that the 
kernel sets aside for the puspose of Dynamic memory allocation. . If yes, how do I do it and what part of the code should be seen. I 
presume that this should be done before the kernel is up.

Thanks,
Anand Gurumurthy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
