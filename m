Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F07998E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 19:58:33 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id b17so31670403pfc.11
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 16:58:33 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h75si50206721pfj.257.2019.01.01.16.58.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 01 Jan 2019 16:58:32 -0800 (PST)
Date: Tue, 1 Jan 2019 16:58:29 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Introduce page_size()
Message-ID: <20190102005829.GF6310@bombadil.infradead.org>
References: <20181231134223.20765-1-willy@infradead.org>
 <20181231230222.zq23mor2y5n67ast@kshutemo-mobl1>
 <20190101063922.GE6310@bombadil.infradead.org>
 <512B2F1D-73EE-46A8-89CC-DBF03CAA0F27@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <512B2F1D-73EE-46A8-89CC-DBF03CAA0F27@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Jan 01, 2019 at 03:11:04PM -0500, Zi Yan wrote:
> On 1 Jan 2019, at 1:39, Matthew Wilcox wrote:
> 
> > On Tue, Jan 01, 2019 at 02:02:22AM +0300, Kirill A. Shutemov wrote:
> >> On Mon, Dec 31, 2018 at 05:42:23AM -0800, Matthew Wilcox wrote:
> >>> It's unnecessarily hard to find out the size of a potentially huge page.
> >>> Replace 'PAGE_SIZE << compound_order(page)' with page_size(page).
> >>
> >> Good idea.
> >>
> >> Should we add page_mask() and page_shift() too?
> >
> > I'm not opposed to that at all.  I also have a patch to add compound_nr():
> >
> > +/* Returns the number of pages in this potentially compound page. */
> > +static inline unsigned long compound_nr(struct page *page)
> > +{
> > +       return 1UL << compound_order(page);
> > +}
> >
> > I just haven't sent it yet ;-)  It should, perhaps, be called page_count()
> > or nr_pages() or something.  That covers most of the remaining users of
> > compound_order() which look awkward.
> 
> We already have hpage_nr_pages() to show the number of pages. Why do we need
> another one?

Not all compound pages are PMD sized.
