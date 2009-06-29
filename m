Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7C4EF6B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 06:10:23 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20090629073423.GA1315@localhost>
References: <20090629073423.GA1315@localhost> <7561.1245768237@redhat.com> <26537.1246086769@redhat.com> <20090627125412.GA1667@cmpxchg.org> <20090628113246.GA18409@localhost> <28c262360906280630n557bb182n5079e33d21ea4a83@mail.gmail.com> <28c262360906280636l93130ffk14086314e2a6dcb7@mail.gmail.com> <20090628142239.GA20986@localhost> <2f11576a0906280801w417d1b9fpe10585b7a641d41b@mail.gmail.com> <20090628151026.GB25076@localhost> <20090629091741.ab815ae7.minchan.kim@barrios-desktop> 
Subject: Re: Found the commit that causes the OOMs
Date: Mon, 29 Jun 2009 11:10:19 +0100
Message-ID: <17678.1246270219@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: dhowells@redhat.com, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes,
                         Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

Wu Fengguang <fengguang.wu@intel.com> wrote:

> Yes, good catch! (sorry I was in a hurry at the time..)

That doesn't compile:

mm/vmscan.c: In function 'do_try_to_free_pages':
mm/vmscan.c:1683: error: too many arguments to function 'zone_reclaimable_pages'
mm/vmscan.c: In function 'balance_pgdat':
mm/vmscan.c:1900: error: too many arguments to function 'zone_reclaimable_pages'
mm/vmscan.c:1944: error: too many arguments to function 'zone_reclaimable_pages'
mm/vmscan.c: In function 'global_reclaimable_pages':
mm/vmscan.c:2115: error: 'zone' undeclared (first use in this function)
mm/vmscan.c:2115: error: (Each undeclared identifier is reported only once
mm/vmscan.c:2115: error: for each function it appears in.)
mm/vmscan.c:2115: error: too many arguments to function 'global_page_state'
mm/vmscan.c:2116: error: too many arguments to function 'global_page_state'
mm/vmscan.c:2119: error: too many arguments to function 'global_page_state'
mm/vmscan.c:2120: error: too many arguments to function 'global_page_state'
mm/vmscan.c: At top level:
mm/vmscan.c:2126: error: conflicting types for 'zone_reclaimable_pages'
include/linux/vmstat.h:170: note: previous declaration of 'zone_reclaimable_pages' was here
make[1]: *** [mm/vmscan.o] Error 1

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
