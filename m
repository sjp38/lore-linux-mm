Message-ID: <20021010162211.15705.qmail@web40502.mail.yahoo.com>
Date: Thu, 10 Oct 2002 09:22:11 -0700 (PDT)
From: Sanjay Kumar <sankumar73@yahoo.com>
Subject: memory reclaiming problem in 2.4.2
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

We are running applications on linux2.4.2 on our embedded box; Linux is being
given around 8.25 MB of memory. At run time we are trying to get 
free memory by killing some of the applications. But even after killing the 
process, the free memory is not getting freed completely, instead it is getting 
locked in form of inactive dirty pages and cache.

Following is the dump of meminfo:
# cat /proc/meminfo
        total:    used:    free:  shared: buffers:  cached:
Mem:   6447104  4931584  1515520        0    40960  2486272
Swap:        0        0        0
MemTotal:         6296 kB
MemFree:          1480 kB
MemShared:           0 kB
Buffers:            40 kB
Cached:           2428 kB
Active:           1696 kB
Inact_dirty:       504 kB
Inact_clean:       268 kB
Inact_target:        0 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:         6296 kB
LowFree:          1480 kB
SwapTotal:           0 kB
SwapFree:            0 kB


>From user space we need to allocate a huge memory space of 3.5 MB; however
allocation more than 2.5 MB fails.

We wanted to know is there is some way to reclaim these dirty pages?
There is a page laundering patch by Rik for 2.4.6; will this be useful for us?

Thanks and Regards,
Sanjay

__________________________________________________
Do you Yahoo!?
Faith Hill - Exclusive Performances, Videos & More
http://faith.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
