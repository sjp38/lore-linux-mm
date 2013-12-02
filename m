Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 928BD6B0031
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 17:51:08 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id md12so19872529pbc.5
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 14:51:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ph10si14489260pbb.199.2013.12.02.14.51.06
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 14:51:07 -0800 (PST)
Date: Mon, 2 Dec 2013 14:51:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/9] mm/rmap: make rmap_walk to get the
 rmap_walk_control argument
Message-Id: <20131202145105.c8027647503eece9a099462f@linux-foundation.org>
In-Reply-To: <1386014973-h0zadm1f-mutt-n-horiguchi@ah.jp.nec.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1385624926-28883-5-git-send-email-iamjoonsoo.kim@lge.com>
	<1386014973-h0zadm1f-mutt-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Mon, 02 Dec 2013 15:09:33 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> > --- a/include/linux/rmap.h
> > +++ b/include/linux/rmap.h
> > @@ -235,11 +235,16 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page);
> >  void page_unlock_anon_vma_read(struct anon_vma *anon_vma);
> >  int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
> >  
> > +struct rmap_walk_control {
> > +	int (*main)(struct page *, struct vm_area_struct *,
> > +					unsigned long, void *);
> 
> Maybe you can add parameters' names to make this prototype more readable.
> 

Yes, I find it quite maddening when the names are left out.  They're really
very useful for understanding what's going on.

The name "main" seems odd as well.  What does "main" mean?  "rmap_one"
was better, but "rmap_one_page" or "rmap_one_pte" or whatever would
be better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
