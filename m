Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF116B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 05:30:42 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p11-v6so4515635wrd.20
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 02:30:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y58si3095294edc.428.2018.04.19.02.30.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Apr 2018 02:30:40 -0700 (PDT)
Subject: Re: [PATCH v3 03/14] mm: Mark pages in use for page tables
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-4-willy@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e3716703-2ab3-e996-64bf-2191dc45a718@suse.cz>
Date: Thu, 19 Apr 2018 11:30:38 +0200
MIME-Version: 1.0
In-Reply-To: <20180418184912.2851-4-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>

On 04/18/2018 08:49 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Define a new PageTable bit in the page_type and use it to mark pages in
> use as page tables.  This can be helpful when debugging crashdumps or

Yep, once I've added such flag for debugging myself :)

> analysing memory fragmentation.  Add a KPF flag to report these pages
> to userspace and update page-types.c to interpret that flag.
> 
> Note that only pages currently accounted as NR_PAGETABLES are tracked
> as PageTable; this does not include pgd/p4d/pud/pmd pages.  Those will
> be the subject of a later patch.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
