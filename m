Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id EEF1B6B5044
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 21:42:29 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id v79so394075pfd.20
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 18:42:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v8si591513ply.126.2018.11.28.18.42.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 28 Nov 2018 18:42:28 -0800 (PST)
Date: Wed, 28 Nov 2018 18:42:22 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: remove pte_lock_deinit()
Message-ID: <20181129024222.GJ10377@bombadil.infradead.org>
References: <20181128235525.58780-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181128235525.58780-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Souptick Joarder <jrdr.linux@gmail.com>, Logan Gunthorpe <logang@deltatee.com>, Keith Busch <keith.busch@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 28, 2018 at 04:55:25PM -0700, Yu Zhao wrote:
> Pagetable page doesn't touch page->mapping or have any used field
> that overlaps with it. No need to clear mapping in dtor. In fact,
> doing so might mask problems that otherwise would be detected by
> bad_page().
> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>

Reviewed-by: Matthew Wilcox <willy@infradead.org>

I do have plans to use page->mapping for pt_mm, but this patch won't
get in my way when I find the round tuits to do that work.
