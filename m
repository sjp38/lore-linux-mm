Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E0EBF6B025F
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:56:28 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id s5so7896088wra.3
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:56:28 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t21sor8036512edd.40.2017.12.19.07.56.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 07:56:27 -0800 (PST)
Date: Tue, 19 Dec 2017 18:56:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 7/8] mm: Document how to use struct page
Message-ID: <20171219155625.etst7kvn2wdixh5t@node.shutemov.name>
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
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>

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

No. For compound pages, only head is on lru.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
