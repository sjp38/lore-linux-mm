Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5E81E6B0037
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 03:12:50 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id hi2so325979wib.10
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 00:12:49 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id u19si9109560wjw.95.2014.07.18.00.12.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 00:12:48 -0700 (PDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so322089wiv.17
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 00:12:48 -0700 (PDT)
Date: Fri, 18 Jul 2014 09:12:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140718071246.GA21565@dhcp22.suse.cz>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
 <20140715082545.GA9366@dhcp22.suse.cz>
 <20140715121935.GB9366@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140715121935.GB9366@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 15-07-14 14:19:35, Michal Hocko wrote:
> [...]
> > +/**
> > + * mem_cgroup_migrate - migrate a charge to another page
> > + * @oldpage: currently charged page
> > + * @newpage: page to transfer the charge to
> > + * @lrucare: page might be on LRU already
> 
> which one? I guess the newpage?
> 
> > + *
> > + * Migrate the charge from @oldpage to @newpage.
> > + *
> > + * Both pages must be locked, @newpage->mapping must be set up.
> > + */
> > +void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
> > +			bool lrucare)
> > +{
> > +	unsigned int nr_pages = 1;
> > +	struct page_cgroup *pc;
> > +
> > +	VM_BUG_ON_PAGE(!PageLocked(oldpage), oldpage);
> > +	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
> > +	VM_BUG_ON_PAGE(PageLRU(oldpage), oldpage);
> > +	VM_BUG_ON_PAGE(PageLRU(newpage), newpage);
> 
> 	VM_BUG_ON_PAGE(PageLRU(newpage) && !lruvec, newpage);

I guess everything except these two notes got addressed.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
