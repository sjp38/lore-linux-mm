Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 09BFE6B0088
	for <linux-mm@kvack.org>; Tue, 19 May 2009 04:14:12 -0400 (EDT)
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first
 class  citizen
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090519081238.GA2121@localhost>
References: <20090516090005.916779788@intel.com>
	 <20090516090448.410032840@intel.com>
	 <84144f020905182339o5fb1e78eved95c4c20fd9ffa7@mail.gmail.com>
	 <1242719063.26820.457.camel@twins>
	 <1242720351.20986.0.camel@penberg-laptop> <20090519081238.GA2121@localhost>
Date: Tue, 19 May 2009 11:14:22 +0300
Message-Id: <1242720862.20986.7.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-05-19 at 16:12 +0800, Wu Fengguang wrote:
> On Tue, May 19, 2009 at 04:05:51PM +0800, Pekka Enberg wrote:
> > Hi Peter,
> > 
> > On Tue, 2009-05-19 at 09:44 +0200, Peter Zijlstra wrote:
> > > Its a sekrit conspiracy against bloat by making JIT'd crap run
> > > slower :-)
> > > 
> > > <rant>
> > > Anyway, I just checked, we install tons of mono junk for _2_
> > > applications, f-spot and tomboy, both are shite and both have
> > > alternatives not requiring this disease.
> > > </rant>
> > 
> > :-)
> > 
> > On Tue, 2009-05-19 at 09:44 +0200, Peter Zijlstra wrote:
> > > But seriously, like Kosaka-san already said, anonymous pages are treated
> > > differently from file pages and should not suffer the same problems.
> > 
> > OK, thanks for the explanation. The comment is a little bit misleading
> > because I got the impression that we don't care about anon exec pages.
> 
> Ah yes!  Will this one dismiss the possible mis-interception?
> 
>                         /*
>                          * Identify referenced, file-backed active pages and
>                          * give them one more trip around the active list. So
>                          * that executable code get better chances to stay in
>                          * memory under moderate memory pressure.  Anon pages
> modified ==>             * are not likely to be evicted by use-once streaming
> modified ==>             * IO, plus JVM can create lots of anon VM_EXEC pages,
> modified ==>             * so we ignore them here.
>                          */
>                         if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
>                                 list_add(&page->lru, &l_active);
>                                 continue;
>                         }

Yes, it's better. Even I can understand it now :-).

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
