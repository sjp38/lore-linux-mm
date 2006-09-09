Received: from leeloo.source.org.ua (localhost [127.0.0.1])
	by leeloo.source.org.ua (Postfix) with ESMTP id 9E4DEA7CFD
	for <linux-mm@kvack.org>; Sun, 10 Sep 2006 00:17:15 +0300 (EEST)
Date: Sun, 10 Sep 2006 00:17:15 +0300
From: Alexander Burnos <alex@localhost.org.ua>
Subject: 2.6 vs 2.4 kernel memory management question
Message-ID: <20060909211715.GB3829@leeloo.source.org.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello!

Sorry if it's not appropriate mail list for this question if it's so,
please, point me to the correct place to ask.

I have several linux (debian) servers with java applications each of
them takes, for examples, 200 mbyte of RAM. I've noticed that on
machines with 2.4 kernels VIRT and RES memory (accordinly to 'top'
values) are equal. So top shows me that VIRT == RES == 200 mbyte
(approximately).
But! On the servers with 2.6 kernel I have another picture, VIRT memory
in several times bigger than RES. For example real memory of java
proccess is 146 mbytes, but virtual - 470 mbytes.

At the firt look it isn't a problem, but when I have several java
processes and summary of their virtual memory is more than physical
memory on the server - operatin system begin swapping although there is
30-50% of free memory (2 Gbyte memory on each machine).
At the end we have machine that fall into hard swapping when big part of
memory is actually free.
I've tried to play with "echo 0 > /proc/sys/vm/swappiness" but it didn't
give me good results.

Please, point me to doc where I can read about "physics" of this process
and where I can make some tunning to avoid this effect of growing
virtual memory on 2.6 kernels?

Maybe, it depends on the difference between NPTL and linuxthreads
realization?

Thank you for your answers!

-- 
WBR,
Alexander Burnos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
