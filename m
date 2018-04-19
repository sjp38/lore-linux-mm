Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B50A6B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 07:31:39 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u56-v6so4706603wrf.18
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 04:31:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e12si2214103edm.403.2018.04.19.04.31.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Apr 2018 04:31:38 -0700 (PDT)
Subject: Re: [PATCH v3 05/14] mm: Move 'private' union within struct page
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-6-willy@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c02eb1b3-b3de-9b17-9a6a-0d1fecca1d4c@suse.cz>
Date: Thu, 19 Apr 2018 13:31:35 +0200
MIME-Version: 1.0
In-Reply-To: <20180418184912.2851-6-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>

On 04/18/2018 08:49 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> By moving page->private to the fourth word of struct page, we can put
> the SLUB counters in the same word as SLAB's s_mem and still do the
> cmpxchg_double trick.  Now the SLUB counters no longer overlap with
> the refcount.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
