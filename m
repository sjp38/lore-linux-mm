Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0D2266B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 09:12:38 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id f6-v6so1692713pgs.13
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 06:12:38 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id e184-v6si6275755pgc.475.2018.04.30.06.12.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 06:12:36 -0700 (PDT)
Date: Mon, 30 Apr 2018 16:12:32 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 11/14] mm: Combine first two unions in struct page
Message-ID: <20180430131232.vvfkl62d4nwskcsa@black.fi.intel.com>
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-12-willy@infradead.org>
 <20180430094704.5jvnnugxtqtzvn5h@kshutemo-mobl1>
 <20180430124216.GA27331@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180430124216.GA27331@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Mon, Apr 30, 2018 at 12:42:16PM +0000, Matthew Wilcox wrote:
> On Mon, Apr 30, 2018 at 12:47:04PM +0300, Kirill A. Shutemov wrote:
> > On Wed, Apr 18, 2018 at 11:49:09AM -0700, Matthew Wilcox wrote:
> > > From: Matthew Wilcox <mawilcox@microsoft.com>
> > > 
> > > This gives us five words of space in a single union in struct page.
> > > The compound_mapcount moves position (from offset 24 to offset 20)
> > > on 64-bit systems, but that does not seem likely to cause any trouble.
> > 
> > Yeah, it should be fine.
> > 
> > Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> I was wondering if it might make sense to make compound_mapcount an
> atomic_long_t.  It'd guarantee no overflow, and prevent the location
> from moving.

It would only make sense if we change mapcount too.

I mean, what the point if the first split_huge_pmd() will cause the
overflow.

-- 
 Kirill A. Shutemov
