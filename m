Received: from WinProxy.anywhere (foresyte.com [209.232.78.226])
	by mta1.snfc21.pbi.net (8.9.3/8.9.3) with SMTP id LAA12534
	for <linux-mm@kvack.org>; Mon, 28 Jun 1999 11:08:27 -0700 (PDT)
Message-ID: <3777B816.BD138CE7@foresyte.com>
Date: Mon, 28 Jun 1999 10:59:52 -0700
From: Jiu Zheng <jzheng@foresyte.com>
MIME-Version: 1.0
Subject: memory usage
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxMM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I have some questions about memory usage:

If you type cat /proc/meminfo, you can see the following messages,

           total:          used:           free:         shared:
buffers:     cached:
Mem:  15015936 10260480   4755456  6352896  1523712  6025216
Swap: 98697216          4096 98693120
MemTotal:     14664 kB
MemFree:       4644 kB
MemShared:     6204 kB
Buffers:       1488 kB
Cached:        5884 kB
SwapTotal:    96384 kB
SwapFree:     96380 kB

Can anybody explain what EXACTLY are shared, buffers, and cached?
One can also get memory usage information of all processes by typing "ps
aux".
Are the numbers (in "RSS" collomn?) having any relationship with those
in /proc/meminfo ?

Thanks,

Jiu


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
