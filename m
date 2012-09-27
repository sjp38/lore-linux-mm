Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 8D7806B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 21:55:02 -0400 (EDT)
Received: by qatp27 with SMTP id p27so4463137qat.14
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 18:55:01 -0700 (PDT)
Date: Wed, 26 Sep 2012 18:54:25 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch for-3.6] mm, thp: fix mapped pages avoiding unevictable
 list on mlock
In-Reply-To: <alpine.DEB.2.00.1209261821380.7745@chino.kir.corp.google.com>
Message-ID: <alpine.LSU.2.00.1209261852500.2303@eggly.anvils>
References: <alpine.DEB.2.00.1209191818490.7879@chino.kir.corp.google.com> <alpine.LSU.2.00.1209192021270.28543@eggly.anvils> <alpine.DEB.2.00.1209261821380.7745@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Wed, 26 Sep 2012, David Rientjes wrote:
> On Wed, 19 Sep 2012, Hugh Dickins wrote:
> 
> > Good catch, and the patch looks right to me, as far as it goes:
> > but does it go far enough?
> > 
> > I hesitate because it looks as if the NR_MLOCK zone page state is
> > maintained (with incs and decs) in ignorance of THP; so although
> > you will be correcting the Unevictable kB with your mlock_vma_page(),
> > the Mlocked kB just above it in /proc/meminfo would still be wrong?
> > 
> 
> Indeed, NR_MLOCK is a separate problem with regard to thp and it's 
> currently incremented once for every hugepage rather than HPAGE_PMD_NR.  
> mlock_vma_page() needs to increment by hpage_nr_pages(page) like 
> add_page_to_lru_list() does.
> 
> > I suppose I'm not sure whether this is material for late-3.6:
> > surely it's not a fix for a recent regression?
> > 
> 
> Ok, sounds good.  If there's no objection, I'd like to ask Andrew to apply 
> this to -mm and remove the cc to stable@vger.kernel.org since the 
> mlock_vma_page() problem above is separate and doesn't conflict with this 
> code, so I'll send a followup patch to address that.
> 
> Thanks!

Sounds right, certainly no objection from me, thanks for taking care of it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
