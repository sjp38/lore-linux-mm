Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4C79B6B0093
	for <linux-mm@kvack.org>; Mon,  4 May 2009 07:44:22 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 4so2927516qwk.44
        for <linux-mm@kvack.org>; Mon, 04 May 2009 04:45:02 -0700 (PDT)
Message-ID: <49FED524.9020602@gmail.com>
Date: Mon, 04 May 2009 08:44:36 -0300
From: Marcos Roriz <marcosrorizinf@gmail.com>
MIME-Version: 1.0
Subject: Memory Concepts [+Newbie]
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm reading Mel Gorman Understating the Linux Virtual Memory Manager and 
also TANENBAUM Modern Operating System I don't get some basic concepts 
of the Memory Management in Linux Kernel.

The first question is, what is a memory bank, It's not clear if its a 
physical section of the memory of if its a chip (physical) itself.

The ZONE_NORMAL zone refer only to kernel direct memory mapped, that 
means only to kernel pages and kernel programs (such as daemons)?

Why is the ZONE_NORMAL so large (896 MB)? How to deal with low memory 
systems?

The ZONE_HIGHMEM zone refer to kernel not mapped directly, so that 
includes userspace programs right?

I googled and searched for all those answers but couldn't find a direct 
and consistent answer, thats why I'm asking for your guys help.

Thanks very much for you time,

Marcos Roriz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
