Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1166E6B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 08:42:19 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id w3-v6so5945354pgv.17
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 05:42:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u12-v6si5940424plm.597.2018.04.30.05.42.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 30 Apr 2018 05:42:17 -0700 (PDT)
Date: Mon, 30 Apr 2018 05:42:16 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 11/14] mm: Combine first two unions in struct page
Message-ID: <20180430124216.GA27331@bombadil.infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-12-willy@infradead.org>
 <20180430094704.5jvnnugxtqtzvn5h@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180430094704.5jvnnugxtqtzvn5h@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Apr 30, 2018 at 12:47:04PM +0300, Kirill A. Shutemov wrote:
> On Wed, Apr 18, 2018 at 11:49:09AM -0700, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > This gives us five words of space in a single union in struct page.
> > The compound_mapcount moves position (from offset 24 to offset 20)
> > on 64-bit systems, but that does not seem likely to cause any trouble.
> 
> Yeah, it should be fine.
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

I was wondering if it might make sense to make compound_mapcount an
atomic_long_t.  It'd guarantee no overflow, and prevent the location
from moving.
