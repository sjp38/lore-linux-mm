Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 784F06B30CB
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:47:38 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id i19-v6so4763522pfi.21
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 02:47:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 7sor27926941pll.40.2018.11.23.02.47.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Nov 2018 02:47:37 -0800 (PST)
Date: Fri, 23 Nov 2018 13:47:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] mm: Remove redundant test from find_get_pages_contig
Message-ID: <20181123104732.gvhdqyddbsiq3i42@kshutemo-mobl1>
References: <20181122213224.12793-1-willy@infradead.org>
 <20181122213224.12793-2-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122213224.12793-2-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>

On Thu, Nov 22, 2018 at 01:32:23PM -0800, Matthew Wilcox wrote:
> After we establish a reference on the page, we check the pointer continues
> to be in the correct position in i_pages.  There's no need to check the
> page->mapping or page->index afterwards; if those can change after we've
> got the reference, they can change after we return the page to the caller.

Hm. IIRC, page->mapping can be set to NULL due truncation, but what about
index? When it can be changed? Truncation doesn't touch it.

-- 
 Kirill A. Shutemov
