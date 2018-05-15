Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E04986B0283
	for <linux-mm@kvack.org>; Tue, 15 May 2018 08:23:38 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id q16-v6so1241467pls.15
        for <linux-mm@kvack.org>; Tue, 15 May 2018 05:23:38 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d1-v6si12416894plr.410.2018.05.15.05.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 15 May 2018 05:23:36 -0700 (PDT)
Date: Tue, 15 May 2018 05:23:35 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v5 12/17] mm: Add pt_mm to struct page
Message-ID: <20180515122335.GF31599@bombadil.infradead.org>
References: <20180504183318.14415-1-willy@infradead.org>
 <20180504183318.14415-13-willy@infradead.org>
 <89ea9412-22fe-d08c-718c-15bc816ec47c@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <89ea9412-22fe-d08c-718c-15bc816ec47c@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Tue, May 15, 2018 at 11:27:25AM +0200, Vlastimil Babka wrote:
> On 05/04/2018 08:33 PM, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > x86 overloads the page->index field to store a pointer to the mm_struct.
> 
> Maybe start the sentence with "For page table pages, ..." or "For pgd
> page table pages, ..." ?

Thanks, done.

> > -			unsigned long _pt_pad_3;
> > +			struct mm_struct *pt_mm;
> 
> Add comment that it's x86-only so somebody doesn't try to write a
> generic code expecting it?

Done.

My plan is to actually make this true for all page table pages so that
we can always track a page table back to its owner, but that's not part
of this patch set, and we can remove the comment when that changes.

That's part of the generic infrastructure we need to be able to survive
an uncorrectable error in a process's page table.
