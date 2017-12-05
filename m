Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB5BC6B0261
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 18:01:26 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a6so1380720pff.17
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 15:01:26 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id i2si783163pgq.7.2017.12.05.15.01.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 15:01:24 -0800 (PST)
Date: Tue, 5 Dec 2017 16:01:23 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2] mm: Add unmap_mapping_pages
Message-ID: <20171205230123.GB20978@linux.intel.com>
References: <20171205154453.GD28760@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171205154453.GD28760@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, "zhangyi (F)" <yi.zhang@huawei.com>, linux-fsdevel@vger.kernel.org

On Tue, Dec 05, 2017 at 07:44:53AM -0800, Matthew Wilcox wrote:
> v2:
>  - Fix inverted mask in dax.c
>  - Pass 'false' instead of '0' for 'only_cows'
>  - nommu definition
> 
> >From ceee2e58548a5264b61000c02371956a1da3bee4 Mon Sep 17 00:00:00 2001
> From: Matthew Wilcox <mawilcox@microsoft.com>
> Date: Tue, 5 Dec 2017 00:15:54 -0500
> Subject: [PATCH] mm: Add unmap_mapping_pages
> 
> Several users of unmap_mapping_range() would much prefer to express
> their range in pages rather than bytes.  Unfortuately, on a 32-bit
> kernel, you have to remember to cast your page number to a 64-bit type
> before shifting it, and four places in the current tree didn't remember
> to do that.  That's a sign of a bad interface.
> 
> Conveniently, unmap_mapping_range() actually converts from bytes into
> pages, so hoist the guts of unmap_mapping_range() into the new function
> unmap_mapping_pages() and convert the callers which want to use pages.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Reported-by: "zhangyi (F)" <yi.zhang@huawei.com>

Looks good.  You can add:

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
