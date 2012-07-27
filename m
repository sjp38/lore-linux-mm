Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 592B96B0044
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 04:43:01 -0400 (EDT)
Date: Fri, 27 Jul 2012 09:42:54 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
Message-ID: <20120727084254.GA612@suse.de>
References: <20120720134937.GG9222@suse.de>
 <20120720141108.GH9222@suse.de>
 <20120720143635.GE12434@tiehlicka.suse.cz>
 <20120720145121.GJ9222@suse.de>
 <alpine.LSU.2.00.1207222033030.6810@eggly.anvils>
 <50118182.8030308@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50118182.8030308@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Larry Woodman <lwoodman@redhat.com>

On Thu, Jul 26, 2012 at 01:42:26PM -0400, Rik van Riel wrote:
> On 07/23/2012 12:04 AM, Hugh Dickins wrote:
> 
> >Please don't be upset if I say that I don't like either of your patches.
> >Mainly for obvious reasons - I don't like Mel's because anything with
> >trylock retries and nested spinlocks worries me before I can even start
> >to think about it; and I don't like Michal's for the same reason as Mel,
> >that it spreads more change around in common paths than we would like.
> 
> I have a naive question.
> 
> In huge_pmd_share, we protect ourselves by taking
> the mapping->i_mmap_mutex.
> 
> Is there any reason we could not take the i_mmap_mutex
> in the huge_pmd_unshare path?
> 

We do, in 3.4 at least - callers of __unmap_hugepage_range hold the
i_mmap_mutex. Locking changes in mmotm and there is a patch there that
needs to be reverted. What tree are you looking at?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
