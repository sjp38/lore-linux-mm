Date: Fri, 14 Jan 2000 02:56:49 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: 1+ GB support (fwd)
Message-ID: <Pine.LNX.4.10.10001140256150.13454-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Could somebody please write an FAQ about this (for use on the
Linux-MM site)... ? :)

Rik
---------- Forwarded message ----------
Date: Thu, 13 Jan 2000 15:19:00 -0800
From: Kelly Alexander <kelly@nvidia.com>
Reply-To: linux-mm-www@nl.linux.org
To: linux-mm-www@nl.linux.org
Subject: 1+ GB support

	
	I've read a bunch of linux news that says that the later kernels
such as 2.3.35 can support more than 1gb of memory.  I've put together a
system with 4gb of RAM (dell 6300, 2x PIII 550 xeon CPUs) and can see that
the kernel reports all 4gb is there and I can use 4gb if running multiple
processes.  However, I've been unable to malloc and use more than 1gb per
process.  Is this a limitation or am I doing something wrong?  I've tried to
use the obsolete FAQ on large memory to give me some ideas of where to poke
around but no luck so far.  Any ideas or pointers for me to investigate?

---
Kelly Alexander
nVidia Corporation    
-
Linux-mm-www: builders list for the Linux-MM website
Archive:      http://humbolt.nl.linux.org/lists/
Web site:     http://www.linux.eu.org/Linux-MM/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
