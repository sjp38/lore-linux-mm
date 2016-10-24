Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6F2280250
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:58:51 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b80so37385161wme.5
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:58:51 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id b10si13737778wmg.36.2016.10.24.11.58.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 11:58:50 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id o81so11139405wma.2
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:58:50 -0700 (PDT)
Date: Mon, 24 Oct 2016 20:58:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Stable 4.4 - NEEDS REVIEW - 1/3] mm: workingset: fix crash in
 shadow node shrinker caused by replace_page_cache_page()
Message-ID: <20161024185848.GD13148@dhcp22.suse.cz>
References: <20161024152605.11707-1-mhocko@kernel.org>
 <20161024152605.11707-2-mhocko@kernel.org>
 <20161024185223.GA28326@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161024185223.GA28326@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Stable tree <stable@vger.kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Antonio SJ Musumeci <trapexit@spawn.link>, Miklos Szeredi <miklos@szeredi.hu>

On Mon 24-10-16 14:52:23, Johannes Weiner wrote:
> On Mon, Oct 24, 2016 at 05:26:03PM +0200, Michal Hocko wrote:
[...]
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index 7ba7dccaf0e7..b28de19aadbf 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -266,6 +266,7 @@ static inline void workingset_node_pages_inc(struct radix_tree_node *node)
> >  
> >  static inline void workingset_node_pages_dec(struct radix_tree_node *node)
> >  {
> > +	VM_BUG_ON(!workingset_node_pages(node));
> >  	node->count--;
> >  }
> 
> We should also pull 21f54ddae449 ("Using BUG_ON() as an assert() is
> _never_ acceptable") into stable on top of this patch to replace the
> BUG_ONs with warnings.
> 
> Otherwise this looks good to me.

OK, I have put that one on top and after the review will post it in one
series. Thanks for the review Johannes!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
