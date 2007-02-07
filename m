Date: Tue, 6 Feb 2007 17:08:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: hugetlb: preserve hugetlb pte dirty state
Message-Id: <20070206170827.d9ec67a2.akpm@linux-foundation.org>
In-Reply-To: <b040c32a0702061647k33c3354csc5d6b28ef3a102f7@mail.gmail.com>
References: <b040c32a0702061306l771d2b71s719cee7cf4713e71@mail.gmail.com>
	<20070206163531.8d524171.akpm@linux-foundation.org>
	<b040c32a0702061647k33c3354csc5d6b28ef3a102f7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Feb 2007 16:47:21 -0800
"Ken Chen" <kenchen@google.com> wrote:

> On 2/6/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > > --- ./mm/hugetlb.c.orig       2007-02-06 08:28:33.000000000 -0800
> > > +++ ./mm/hugetlb.c    2007-02-06 08:29:47.000000000 -0800
> > > @@ -389,6 +389,8 @@
> > >                       continue;
> > >
> > >               page = pte_page(pte);
> > > +             if (pte_dirty(pte))
> > > +                     set_page_dirty(page);
> > >               list_add(&page->lru, &page_list);
> > >       }
> > >       spin_unlock(&mm->page_table_lock);
> >
> > I guess we really should be setting these pages dirty at fault-time, as we're
> > now doing with regular pages.
> 
> yeah, I wonder why I didn't do that :-P  Especially after I asked you
> a similar question the other day.  I will redo it and retest.
> 

No rush - the code should work OK as-is and given the total catastrophe
which that change caused in core mm, making the same change to hugepages
should be done with some care and thought and maintainer-poking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
