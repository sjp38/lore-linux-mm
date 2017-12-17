Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 55ED36B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 20:15:35 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id d3so2906102plj.22
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 17:15:35 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o18si7320486pfa.3.2017.12.16.17.15.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Dec 2017 17:15:33 -0800 (PST)
Date: Sat, 16 Dec 2017 17:15:30 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 7/8] mm: Document how to use struct page
Message-ID: <20171217011530.GA20450@bombadil.infradead.org>
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-8-willy@infradead.org>
 <4d963b8f-0010-fd20-013e-f53f27c8a7ce@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4d963b8f-0010-fd20-013e-f53f27c8a7ce@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Sat, Dec 16, 2017 at 09:47:16AM -0800, Randy Dunlap wrote:
> On 12/16/2017 08:44 AM, Matthew Wilcox wrote:
> > + * even after they have been recycled to a different purpose.  The page cache
> > + * will read and writes some of the fields in struct page to lock the page,
> 
> "will read and writes" seems awkward to me.
> Can that be:
>     * reads and writes

Sure!  I think I intended to write "will read and write", but fewer words is
usually better.

Thanks for reading.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
