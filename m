Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id l170lQt8005725
	for <linux-mm@kvack.org>; Wed, 7 Feb 2007 00:47:26 GMT
Received: from ug-out-1314.google.com (ugfe2.prod.google.com [10.66.182.2])
	by spaceape14.eur.corp.google.com with ESMTP id l170lEFL023818
	for <linux-mm@kvack.org>; Wed, 7 Feb 2007 00:47:22 GMT
Received: by ug-out-1314.google.com with SMTP id e2so42822ugf
        for <linux-mm@kvack.org>; Tue, 06 Feb 2007 16:47:21 -0800 (PST)
Message-ID: <b040c32a0702061647k33c3354csc5d6b28ef3a102f7@mail.gmail.com>
Date: Tue, 6 Feb 2007 16:47:21 -0800
From: "Ken Chen" <kenchen@google.com>
Subject: Re: hugetlb: preserve hugetlb pte dirty state
In-Reply-To: <20070206163531.8d524171.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0702061306l771d2b71s719cee7cf4713e71@mail.gmail.com>
	 <20070206163531.8d524171.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/6/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > --- ./mm/hugetlb.c.orig       2007-02-06 08:28:33.000000000 -0800
> > +++ ./mm/hugetlb.c    2007-02-06 08:29:47.000000000 -0800
> > @@ -389,6 +389,8 @@
> >                       continue;
> >
> >               page = pte_page(pte);
> > +             if (pte_dirty(pte))
> > +                     set_page_dirty(page);
> >               list_add(&page->lru, &page_list);
> >       }
> >       spin_unlock(&mm->page_table_lock);
>
> I guess we really should be setting these pages dirty at fault-time, as we're
> now doing with regular pages.

yeah, I wonder why I didn't do that :-P  Especially after I asked you
a similar question the other day.  I will redo it and retest.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
