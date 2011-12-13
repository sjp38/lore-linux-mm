Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 1C4CF6B0256
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 08:58:42 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/4] mm: bootmem / page allocator bootstrap fixlets
Date: Tue, 13 Dec 2011 14:58:27 +0100
Message-Id: <1323784711-1937-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Uwe,

here is a follow-up to your bootmem micro optimizations.  3 and 4
directly relate to the discussion, 1 and 2 are cleanups I had sitting
around anyway.

Unfortunately, I can't test them as x86 kernels no longer build with
CONFIG_NO_BOOTMEM=n, but I suspect that you might have access to
non-x86 machines ;-) so if you can, please give this a spin - I don't
want this stuff to go in untested.

[ Fun fact: nobootmem.c is 400 lines of bootmem API emulation that is
  just incompatible enough that one can not switch between bootmem and
  nobootmem without touching callsites. ]

 mm/bootmem.c    |   22 ++++++++++------------
 mm/page_alloc.c |   33 ++++++++++++---------------------
 2 files changed, 22 insertions(+), 33 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
