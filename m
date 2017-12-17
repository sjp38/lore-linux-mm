Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F3AB6B0033
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 08:06:23 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id p8so4050709wrh.17
        for <linux-mm@kvack.org>; Sun, 17 Dec 2017 05:06:23 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b23sor6762332edd.33.2017.12.17.05.06.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Dec 2017 05:06:21 -0800 (PST)
Date: Sun, 17 Dec 2017 16:06:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/8] Restructure struct page
Message-ID: <20171217130619.ygl2gegemrh6yh7v@node.shutemov.name>
References: <20171216164425.8703-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171216164425.8703-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Sat, Dec 16, 2017 at 08:44:17AM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> This series does not attempt any grand restructuring as I proposed last
> week.  Instead, it cures the worst of the indentitis, fixes the
> documentation and reduces the ifdeffery.  The only layout change is
> compound_dtor and compound_order are each reduced to one byte.  At
> least, that's my intent.  

For whole patchset:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
