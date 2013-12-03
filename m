Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9B35B6B0044
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:00:53 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id lf10so2232193pab.14
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:00:53 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id n8si49698567pax.218.2013.12.02.18.00.51
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 18:00:52 -0800 (PST)
Date: Tue, 3 Dec 2013 11:03:16 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 4/9] mm/rmap: make rmap_walk to get the rmap_walk_control
 argument
Message-ID: <20131203020316.GB31168@lge.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1385624926-28883-5-git-send-email-iamjoonsoo.kim@lge.com>
 <1386014973-h0zadm1f-mutt-n-horiguchi@ah.jp.nec.com>
 <20131202145105.c8027647503eece9a099462f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131202145105.c8027647503eece9a099462f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Dec 02, 2013 at 02:51:05PM -0800, Andrew Morton wrote:
> On Mon, 02 Dec 2013 15:09:33 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > > --- a/include/linux/rmap.h
> > > +++ b/include/linux/rmap.h
> > > @@ -235,11 +235,16 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page);
> > >  void page_unlock_anon_vma_read(struct anon_vma *anon_vma);
> > >  int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
> > >  
> > > +struct rmap_walk_control {
> > > +	int (*main)(struct page *, struct vm_area_struct *,
> > > +					unsigned long, void *);
> > 
> > Maybe you can add parameters' names to make this prototype more readable.
> > 
> 
> Yes, I find it quite maddening when the names are left out.  They're really
> very useful for understanding what's going on.

Okay. Will do.

> 
> The name "main" seems odd as well.  What does "main" mean?  "rmap_one"
> was better, but "rmap_one_page" or "rmap_one_pte" or whatever would
> be better.

Okay. I will think better name.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
