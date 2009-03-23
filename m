Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 907A66B00CE
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 05:45:22 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20090323001418.GA32758@cmpxchg.org>
References: <20090323001418.GA32758@cmpxchg.org> <20090321102044.GA3427@cmpxchg.org> <1237752784-1989-1-git-send-email-hannes@cmpxchg.org> <20090323084423.490C.A69D9226@jp.fujitsu.com>
Subject: Re: [patch 1/3] mm: decouple unevictable lru from mmu
Date: Mon, 23 Mar 2009 10:48:25 +0000
Message-ID: <12087.1237805305@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: dhowells@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.com>, MinChan Kim <minchan.kim@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Johannes Weiner <hannes@cmpxchg.org> wrote:

> David, why do we need two Kconfig symbols for mlock and the mlock page
> bit?  Don't we always provide mlock on mmu and never on nommu?

Because whilst the PG_mlocked doesn't exist if we don't have mlock() because
we're in NOMMU mode, that does not imply that it _does_ exist if we _do_ have
mlock() as it's also contingent on having the unevictable LRU.

Not only that, CONFIG_HAVE_MLOCK used in mm/internal.h to switch some stuff
out based on whether we have mlock() available or not - which is not the same
as whether we have PG_mlocked or not.

Mainly I thought it made the train of logic easier.

Note that neither symbol is actually manually adjustable.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
