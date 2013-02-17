Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 81AAB6B0002
	for <linux-mm@kvack.org>; Sun, 17 Feb 2013 17:03:03 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id b57so2510946eek.4
        for <linux-mm@kvack.org>; Sun, 17 Feb 2013 14:03:01 -0800 (PST)
Message-ID: <51215393.1070409@suse.cz>
Date: Sun, 17 Feb 2013 23:02:59 +0100
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: kswapd craziness round 2
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>

Hi,

You still feel the sour taste of the "kswapd craziness in v3.7" thread,
right? Welcome to the hell, part two :{.

I believe this started happening after update from
3.8.0-rc4-next-20130125 to 3.8.0-rc7-next-20130211. The same as before,
many hours of uptime are needed and perhaps some suspend/resume cycles
too. Memory pressure is not high, plenty of I/O cache:
# free
             total       used       free     shared    buffers     cached
Mem:       6026692    5571184     455508          0     351252    2016648
-/+ buffers/cache:    3203284    2823408
Swap:            0          0          0

kswap is working very toughly though:
root       580  0.6  0.0      0     0 ?        S    uno12  46:21 [kswapd0]

This happens on I/O activity right now. For example by updatedb or find
/. This is what the stack trace of kswapd0 looks like:
[<ffffffff8113c431>] shrink_slab+0xa1/0x2d0
[<ffffffff8113ecd1>] kswapd+0x541/0x930
[<ffffffff810a3000>] kthread+0xc0/0xd0
[<ffffffff816beb5c>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

Any ideas?

thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
