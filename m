Received: from d23rh901.au.ibm.com (d23rh901.au.ibm.com [9.185.167.100])
	by ausmtp02.au.ibm.com (8.12.1/8.12.1) with ESMTP id g7FHFdK4356672
	for <linux-mm@kvack.org>; Fri, 16 Aug 2002 03:15:39 +1000
Received: from d23m0067.in.ibm.com (d23m0067.in.ibm.com [9.184.199.180])
	by d23rh901.au.ibm.com (8.12.3/NCO/VER6.3) with ESMTP id g7FHICHV038666
	for <linux-mm@kvack.org>; Fri, 16 Aug 2002 03:18:13 +1000
Subject: Re: oom_killer - Does not perform when stress-tested (system hangs)
Message-ID: <OF634085C7.4F3F3305-ON65256C16.005D8A8C@in.ibm.com>
From: "Srikrishnan Sundararajan" <srikrishnan@in.ibm.com>
Date: Thu, 15 Aug 2002 22:32:56 +0530
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I  used kernel 2.4.19. This has a few changes in oom_kill.c . It works well
on my intel PC.
ie. Even when I run 500 instances of my memory grabbing program, the
oom_killer is able to kill these errant processes and makes the machine
usable. (No hangs) Hats off to oom_kill!

Thanks,
Srikrishnan




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
