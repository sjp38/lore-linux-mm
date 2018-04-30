Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D043F6B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 06:04:50 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id f133-v6so2566673lfg.18
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 03:04:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x130-v6sor242388lfd.2.2018.04.30.03.04.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Apr 2018 03:04:49 -0700 (PDT)
Date: Mon, 30 Apr 2018 12:44:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 10/14] mm: Move lru union within struct page
Message-ID: <20180430094453.qpc2hrfe4xlvtnxe@kshutemo-mobl1>
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-11-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180418184912.2851-11-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Apr 18, 2018 at 11:49:08AM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Since the LRU is two words, this does not affect the double-word
> alignment of SLUB's freelist.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
