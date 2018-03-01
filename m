Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2426B000D
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 09:51:01 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q2so2713431pgn.22
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 06:51:01 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i11si3113929pfi.388.2018.03.01.06.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 01 Mar 2018 06:51:00 -0800 (PST)
Date: Thu, 1 Mar 2018 06:50:58 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 0/4] Split page_type out from mapcount
Message-ID: <20180301145058.GA19662@bombadil.infradead.org>
References: <20180228223157.9281-1-willy@infradead.org>
 <20180301081750.42b135c3@mschwideX1>
 <20180301124412.gm6jxwzyfskzxspa@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180301124412.gm6jxwzyfskzxspa@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org

On Thu, Mar 01, 2018 at 03:44:12PM +0300, Kirill A. Shutemov wrote:
> On Thu, Mar 01, 2018 at 08:17:50AM +0100, Martin Schwidefsky wrote:
> > Yeah, that is a nasty bit of code. On s390 we have 2K page tables (pte)
> > but 4K pages. If we use full pages for the pte tables we waste 2K of
> > memory for each of the tables. So we allocate 4K and split it into two
> > 2K pieces. Now we have to keep track of the pieces to be able to free
> > them again.
> 
> Have you considered to use slab for page table allocation instead?
> IIRC some architectures practice this already.

You're not allowed to do that any more.  Look at pgtable_page_ctor(),
or rather ptlock_init().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
