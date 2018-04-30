Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id C1CA46B0008
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 06:04:51 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id f16-v6so2626646lfl.3
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 03:04:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u5-v6sor1238400lfu.96.2018.04.30.03.04.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Apr 2018 03:04:50 -0700 (PDT)
Date: Mon, 30 Apr 2018 12:38:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 05/14] mm: Move 'private' union within struct page
Message-ID: <20180430093843.no23h6zn6lcqqots@kshutemo-mobl1>
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-6-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180418184912.2851-6-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Apr 18, 2018 at 11:49:03AM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> By moving page->private to the fourth word of struct page, we can put
> the SLUB counters in the same word as SLAB's s_mem and still do the
> cmpxchg_double trick.  Now the SLUB counters no longer overlap with
> the refcount.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
