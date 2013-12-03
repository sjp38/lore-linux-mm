Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id E1E656B005A
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:03:16 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kl14so2198652pab.5
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:03:16 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ts1si12624028pbc.80.2013.12.02.18.03.14
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 18:03:15 -0800 (PST)
Date: Tue, 3 Dec 2013 11:05:40 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 5/9] mm/rmap: extend rmap_walk_xxx() to cope with
 different cases
Message-ID: <20131203020540.GC31168@lge.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1385624926-28883-6-git-send-email-iamjoonsoo.kim@lge.com>
 <1386014982-lfutnpr2-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386014982-lfutnpr2-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Dec 02, 2013 at 03:09:42PM -0500, Naoya Horiguchi wrote:
> > diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> > index 0f65686..58624b4 100644
> > --- a/include/linux/rmap.h
> > +++ b/include/linux/rmap.h
> > @@ -239,6 +239,12 @@ struct rmap_walk_control {
> >  	int (*main)(struct page *, struct vm_area_struct *,
> >  					unsigned long, void *);
> >  	void *arg;	/* argument to main function */
> > +	int (*main_done)(struct page *page);	/* check exit condition */
> > +	int (*file_nonlinear)(struct page *, struct address_space *,
> > +					struct vm_area_struct *vma);
> > +	struct anon_vma *(*anon_lock)(struct page *);
> > +	int (*vma_skip)(struct vm_area_struct *, void *);
> 
> Can you add some comments about how these callbacks work and when it
> should be set to for future users?  For example, anon_lock() are
> used to override the default behavior and it's not trivial.

Okay. I will add.

> 
> > +	void *skip_arg;	/* argument to vma_skip function */
> 
> I think that it's better to move this field into the structure pointed
> to by arg (which can be defined by each caller in its own way) and pass
> arg to *vma_skip().

Will do.

Thanks.

> 
> Thanks,
> Naoya Horiguchi
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
