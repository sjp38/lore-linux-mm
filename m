Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 64DFA6B0268
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:12:27 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x10so4652496pgx.12
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:12:27 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x186si3609340pgb.437.2017.12.19.08.12.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Dec 2017 08:12:26 -0800 (PST)
Date: Tue, 19 Dec 2017 08:12:17 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 7/8] mm: Document how to use struct page
Message-ID: <20171219161217.GC30842@bombadil.infradead.org>
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-8-willy@infradead.org>
 <alpine.DEB.2.20.1712190952470.16727@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1712190952470.16727@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Tue, Dec 19, 2017 at 09:53:16AM -0600, Christopher Lameter wrote:
> On Sat, 16 Dec 2017, Matthew Wilcox wrote:
> 
> > + * If you allocate pages of order > 0, you can use the fields in the struct
> > + * page associated with each page, but bear in mind that the pages may have
> > + * been inserted individually into the page cache, so you must use the above
> > + * three fields in a compatible way for each struct page.
> 
> If they are inserted into the page cache then also other fields are
> required like the lru one right?

The page cache won't touch the LRU field until it has at least pinned
the page.  This text is explaining what may happen to a page during
the process of the page cache trying (and failing) to pin the page,
which can happen after your driver has allocated the page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
