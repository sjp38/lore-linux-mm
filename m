Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 071B16B0008
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 03:20:28 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id p2so5862547wre.19
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 00:20:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b10sor3887738edk.33.2018.03.02.00.20.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 00:20:26 -0800 (PST)
Date: Fri, 2 Mar 2018 11:20:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 3/4] mm: Mark pages allocated through vmalloc
Message-ID: <20180302082014.4zlhvot6lzg75x66@node.shutemov.name>
References: <20180301211523.21104-1-willy@infradead.org>
 <20180301211523.21104-4-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180301211523.21104-4-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, linux-api@vger.kernel.org

On Thu, Mar 01, 2018 at 01:15:22PM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Use a bit in page_type to mark pages which have been allocated through
> vmalloc.  This can be helpful when debugging crashdumps or analysing
> memory fragmentation.  Add a KPF flag to report these pages to userspace
> and update page-types.c to interpret that flag.
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
