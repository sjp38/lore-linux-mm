Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 02F0B6B0033
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 06:32:43 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c82so11632780wme.8
        for <linux-mm@kvack.org>; Fri, 29 Dec 2017 03:32:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z19si20400714wrg.127.2017.12.29.03.32.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Dec 2017 03:32:40 -0800 (PST)
Date: Fri, 29 Dec 2017 12:32:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/3] mm, migrate: remove reason argument from
 new_page_t
Message-ID: <20171229113237.GA27077@dhcp22.suse.cz>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-3-mhocko@kernel.org>
 <5881ED15-2645-4D62-B558-9007DA9DE3D5@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5881ED15-2645-4D62-B558-9007DA9DE3D5@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 26-12-17 21:12:38, Zi Yan wrote:
> On 8 Dec 2017, at 11:15, Michal Hocko wrote:
[...]
> > @@ -1622,7 +1608,6 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
> >  		}
> >  		chunk_node = NUMA_NO_NODE;
> >  	}
> > -	err = 0;
> 
> This line can be merged into Patch 1. Or did I miss anything?

Yes, I will move it there.

> >  out_flush:
> >  	/* Make sure we do not overwrite the existing error */
> >  	err1 = do_move_pages_to_node(mm, &pagelist, chunk_node);
> > diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> > index 165ed8117bd1..53d801235e22 100644
> > --- a/mm/page_isolation.c
> > +++ b/mm/page_isolation.c
> > @@ -293,8 +293,7 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
> >  	return pfn < end_pfn ? -EBUSY : 0;
> >  }
> >
> > -struct page *alloc_migrate_target(struct page *page, unsigned long private,
> > -				  int **resultp)
> > +struct page *alloc_migrate_target(struct page *page, unsigned long private)
> >  {
> >  	return new_page_nodemask(page, numa_node_id(), &node_states[N_MEMORY]);
> >  }
> > -- 
> > 2.15.0
> 
> Everything else looks good to me.
> 
> Reviewed-by: Zi Yan <zi.yan@cs.rutgers.edu>

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
