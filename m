Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 27A6E6B0008
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 07:44:26 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 65so3971635wrn.7
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 04:44:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b10sor2718638edk.33.2018.03.01.04.44.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Mar 2018 04:44:24 -0800 (PST)
Date: Thu, 1 Mar 2018 15:44:12 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 0/4] Split page_type out from mapcount
Message-ID: <20180301124412.gm6jxwzyfskzxspa@node.shutemov.name>
References: <20180228223157.9281-1-willy@infradead.org>
 <20180301081750.42b135c3@mschwideX1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180301081750.42b135c3@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org

On Thu, Mar 01, 2018 at 08:17:50AM +0100, Martin Schwidefsky wrote:
> On Wed, 28 Feb 2018 14:31:53 -0800
> Matthew Wilcox <willy@infradead.org> wrote:
> 
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > I want to use the _mapcount field to record what a page is in use as.
> > This can help with debugging and we can also expose that information to
> > userspace through /proc/kpageflags to help diagnose memory usage (not
> > included as part of this patch set).
> > 
> > First, we need s390 to stop using _mapcount for its own purposes;
> > Martin, I hope you have time to look at this patch.  I must confess I
> > don't quite understand what the different bits are used for in the upper
> > nybble of the _mapcount, but I tried to replicate what you were doing
> > faithfully.
> 
> Yeah, that is a nasty bit of code. On s390 we have 2K page tables (pte)
> but 4K pages. If we use full pages for the pte tables we waste 2K of
> memory for each of the tables. So we allocate 4K and split it into two
> 2K pieces. Now we have to keep track of the pieces to be able to free
> them again.

Have you considered to use slab for page table allocation instead?
IIRC some architectures practice this already.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
