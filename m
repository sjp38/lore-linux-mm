Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 657F96B0009
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 03:22:10 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id d12so5079154wri.4
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 00:22:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g27sor3910229edf.34.2018.03.02.00.22.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 00:22:09 -0800 (PST)
Date: Fri, 2 Mar 2018 11:21:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 4/4] mm: Mark pages in use for page tables
Message-ID: <20180302082156.ty6nchnmwpniicyb@node.shutemov.name>
References: <20180301211523.21104-1-willy@infradead.org>
 <20180301211523.21104-5-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180301211523.21104-5-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, linux-api@vger.kernel.org

On Thu, Mar 01, 2018 at 01:15:23PM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Define a new PageTable bit in the page_type and use it to mark pages in
> use as page tables.  This can be helpful when debugging crashdumps or
> analysing memory fragmentation.  Add a KPF flag to report these pages
> to userspace and update page-types.c to interpret that flag.

I guess it's worth noting in the commit message that PGD and P4D page
tables are not acoounted to NR_PAGETABLE and not marked with PageTable().
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
