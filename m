Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F3F376B0038
	for <linux-mm@kvack.org>; Fri, 12 May 2017 04:51:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c2so38273632pfd.9
        for <linux-mm@kvack.org>; Fri, 12 May 2017 01:51:32 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id w90si2861081pfj.142.2017.05.12.01.51.31
        for <linux-mm@kvack.org>;
        Fri, 12 May 2017 01:51:32 -0700 (PDT)
Received: from localhost ([127.0.0.1])
	by localhost with esmtp (Exim 4.89)
	(envelope-from <arthur.marsh@internode.on.net>)
	id 1d96IJ-0003LP-RB
	for linux-mm@kvack.org; Fri, 12 May 2017 18:21:27 +0930
From: Arthur Marsh <arthur.marsh@internode.on.net>
Subject: 8 Gigabytes and constantly swapping
Message-ID: <171e8fa1-3f14-dc18-09b5-48399b250a30@internode.on.net>
Date: Fri, 12 May 2017 18:21:27 +0930
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I've been building the Linus git head kernels as the source gets updated 
and the one built about 3 hours ago managed to get stuck with kswapd0 as 
the highest consumer of CPU cycles (but still under 1 percent) of 
processes listed by top for over 15 minutes, after which I hit the power 
switch and rebooted with a Debian 4.11.0 kernel.

The previous kernel built less than 24 hours earlier did not have this 
problem.

CPU is an Athlon64 (Athlon II X4, 4 cores), RAM is 8GiB, swap is 4GiB, 
load was mainly firefox and chromium. Opening a new window in chromium 
seemed to help trigger the problem.

It's not much information to go on, just wondered if anyone else had 
experienced similar issues?

I'm happy to supply more configuration information and run tests 
including with kernels built with test patches applied.

Arthur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
