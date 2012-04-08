Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 77F6F6B004A
	for <linux-mm@kvack.org>; Sun,  8 Apr 2012 07:39:37 -0400 (EDT)
Date: Sun, 8 Apr 2012 13:39:25 +0200
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: BUG: Bad rss-counter state
Message-ID: <20120408113925.GA292@x4>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>

I've hit the following warning after I've tried to link Firofox's libxul
with "-flto -lto-partition=none" on my machine with 8GB memory. I've
killed the process after it used all the memory and 90% of my swap
space. Before the machine was rebooted I saw these messages:

Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020813c380 idx:1 val:-1
Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020813c380 idx:2 val:1
Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88021503bb80 idx:1 val:-1
Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff8801fb643b80 idx:1 val:-1
Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff8801fb643b80 idx:2 val:1
Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88021503bb80 idx:2 val:1
Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020a4ff800 idx:1 val:-1
Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020a4ff800 idx:2 val:1
Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020813ce00 idx:1 val:-1
Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff88020813ce00 idx:2 val:1
Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff8801fadda680 idx:1 val:-1
Apr  8 13:11:08 x4 kernel: BUG: Bad rss-counter state mm:ffff8801fadda680 idx:2 val:1

These warnings were introduced by c3f0327f8e9d7. Wouldn't it make sense to hide
them under some debugging option? AFAICS they contain no information that could
be of any use to a casual user.

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
