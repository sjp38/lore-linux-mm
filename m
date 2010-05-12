Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BE08E6B0202
	for <linux-mm@kvack.org>; Wed, 12 May 2010 00:54:25 -0400 (EDT)
Received: by vws7 with SMTP id 7so1559677vws.14
        for <linux-mm@kvack.org>; Tue, 11 May 2010 21:54:23 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 11 May 2010 21:54:23 -0700
Message-ID: <AANLkTinkQLObl8EVFtlLyqVHF-q_cZNnDUumdmQjmBLx@mail.gmail.com>
Subject: Newbie question about 2.4.21 kernel /proc/meminfo caculation
From: Vincent Li <vincent.mc.li@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I am running an old kernel  2.4.21, I am curious how each items add up
to the MemTotal or any simple addition math in them?

for example:

 # cat /proc/meminfo
        total:    used:    free:  shared: buffers:  cached:
Mem:  1049841664 1024647168 25194496        0 31010816 163115008
Swap: 2371338240 26906624 2344431616
MemTotal:      1025236 kB
MemFree:         24604 kB
MemShared:           0 kB
Committed:      257936 kB
Buffers:         30284 kB
Cached:         148412 kB
SwapCached:      10880 kB
Active:         276704 kB
ActiveAnon:     164016 kB
ActiveCache:    112688 kB
Inact_dirty:     37688 kB
Inact_laundry:   15400 kB
Inact_clean:     14888 kB
Inact_target:    68936 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:      1025236 kB
LowFree:         24604 kB
SwapTotal:     2315760 kB
SwapFree:      2289484 kB
CommitLimit:   2828376 kB
Committed_AS:   257936 kB
HugePages_Total:   154
HugePages_Free:      0
Hugepagesize:     4096 kB

I found that Inact_target = Inact_dirty + Inact_laundry + Inact_clean, but

MemTotal = MemFree + Buffers + Cached + Active + Inact_target +
CommitLimted_AS + ?

Tried to dig into 2.4.21 kernel source code, have not be able to find
those memory data caculations, any pointer would be greatly
appreciated!

Thanks

Vincent Li

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
