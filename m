Received: from mel (3-1-37.ore.fiber.net [209.90.103.38])
	by mail.fiber.net (8.11.6/8.11.3) with ESMTP id g2FGrXj12731
	for <linux-mm@kvack.org>; Fri, 15 Mar 2002 09:53:33 -0700 (MST)
From: "Al T" <at@fiber.net>
Date: Fri, 15 Mar 2002 09:53:54 -0700
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Subject: Set file cache size (2.4.18)
Reply-to: at@fiber.net
Message-ID: <3C91C4B2.8458.19B077CE@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I am currently experimenting Linux on an old laptop I got cheap.  It has 
a max. of 24 MB of ram and an ISA IDE controller.  It is an old 
machine and runs quite well.  I built my own Linux system to maximize 
its power.

But, when I load large programs (KDE 2, for example), the system 
slows down to a crawl.  This is what I've been able to figure out:

- KDE 2 is a memory hog.  In order to compensate for that, a lot of 
swap must be used.  But, with a 3 MB/sec transfer speed, it's just not 
very fast.

- According to TOP, the CPU is not in heavy use.  It is usually 30% 
idle during the process, meaning the bottleneck is I/O.

- At the end of the process, the swap usage is ~18,00k, with ~10,000k 
in buffer/cache.

- X is not a problem, since it can be loaded without using swap.

Based on this, I realized memory has been flipped around: what should 
be in disk (files) is now in memory (cache), and what should be in 
memory is now in disk (swap).

I remember in Windows 95 it was possible to set the minimum and 
maximum values for the file cache.  Tweaking these values increased 
performance on low memory systems, since it would ensure large 
amounts of memory were not used to cache the disk and memory 
pages would not be thrown out to disk.

I've looked through /proc and on the internet for a way to change the 
maximum cache size.  It seems like it was available on early 2.4 
kernels, but it's not in the 2.4.18 kernel.

How do I restrict the size of the cache and buffer?

@
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
