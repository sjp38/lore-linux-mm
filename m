Subject: rmap15a swappy?
From: Sean Neakums <sneakums@zork.net>
Date: Thu, 12 Dec 2002 17:46:49 +0000
Message-ID: <6uu1hjruye.fsf@zork.zork.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I just fitted an extra 512M of RAM to my laptop, and though there is
currently about 400M free, it is still hitting swap.  I seem to recall
that older rmaps generally only started to page stuff out when there
was no more memory free.  (My recollection may be faulty, though.)

Some random info:

[revox(~)] uname -a
Linux revox 2.4.20-rmap15a-4 #1 Mon Dec 9 12:47:13 GMT 2002 i686 unknown unknown GNU/Linux
[revox(~)] cat /proc/meminfo 
        total:    used:    free:  shared: buffers:  cached:
Mem:  792940544 288563200 504377344        0  3063808 184758272
Swap: 539852800 34787328 505065472
MemTotal:       774356 kB
MemFree:        492556 kB
MemShared:           0 kB
Buffers:          2992 kB
Cached:         146456 kB
SwapCached:      33972 kB
Active:         110840 kB
ActiveAnon:      78764 kB
ActiveCache:     32076 kB
Inact_dirty:         0 kB
Inact_laundry:  139960 kB
Inact_clean:      7644 kB
Inact_target:    51688 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       774356 kB
LowFree:        492556 kB
SwapTotal:      527200 kB
SwapFree:       493228 kB
[revox(~)] uptime
 17:42:26 up 41 min,  6 users,  load average: 0.00, 0.02, 0.03

-- 
 /                          |
[|] Sean Neakums            |  Questions are a burden to others;
[|] <sneakums@zork.net>     |      answers a prison for oneself.
 \                          |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
