Message-ID: <20030320231840.33322.qmail@web10101.mail.yahoo.com>
Date: Thu, 20 Mar 2003 15:18:40 -0800 (PST)
From: Innocent Azinyue <azinyue@yahoo.com>
Subject: caching issues
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi there, 

running a 2.4.20 kernel, I realize that the cache is
not emptied when the system runs out of memory. Assets
that were copied using "cp" seem to be cached, and the
memory is not freed after. System performance drops.

A view of /proc/meminfo:

        total:    used:    free:  shared: buffers: 
cached:
Mem:  3952689152 3932549120 20140032        0 24858624
3617976320
Swap: 2147467264  5730304 2141736960
MemTotal:      3860048 kB
MemFree:         19668 kB
MemShared:           0 kB
Buffers:         24276 kB
Cached:        3529720 kB
SwapCached:       3460 kB
Active:         887940 kB
Inactive:      2816016 kB
HighTotal:     3211200 kB
HighFree:         2044 kB
LowTotal:       648848 kB
LowFree:         17624 kB
SwapTotal:     2097136 kB
SwapFree:      2091540 kB


this behaviour is not observed in the 2.4.18 kernel.

Can anyone through some light on how to fix this ?!?

thanks

azieh

__________________________________________________
Do you Yahoo!?
Yahoo! Platinum - Watch CBS' NCAA March Madness, live on your desktop!
http://platinum.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
