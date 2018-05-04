Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id DE2726B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 10:55:33 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 6-v6so2492932itl.6
        for <linux-mm@kvack.org>; Fri, 04 May 2018 07:55:33 -0700 (PDT)
Received: from resqmta-po-05v.sys.comcast.net (resqmta-po-05v.sys.comcast.net. [2001:558:fe16:19:96:114:154:164])
        by mx.google.com with ESMTPS id s64-v6si14457065ioi.148.2018.05.04.07.55.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 07:55:32 -0700 (PDT)
Date: Fri, 4 May 2018 09:55:30 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v4 07/16] slub: Remove page->counters
In-Reply-To: <20180503182823.GB1562@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.21.1805040953540.10847@nuc-kabylake>
References: <20180430202247.25220-1-willy@infradead.org> <20180430202247.25220-8-willy@infradead.org> <alpine.DEB.2.21.1805011148060.16325@nuc-kabylake> <20180502172639.GC2737@bombadil.infradead.org> <20180502221702.a2ezdae6akchroze@black.fi.intel.com>
 <20180503005223.GB21199@bombadil.infradead.org> <alpine.DEB.2.21.1805031001510.6701@nuc-kabylake> <20180503182823.GB1562@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>

On Thu, 3 May 2018, Matthew Wilcox wrote:

> OK.  Do you want the conversion of slub to using slub_freelist and slub_list
> as part of this patch series as well, then?

Not sure if that is needed. Dont like allocator specific names.

> Oh, and what do you want to do about cache_from_obj() in mm/slab.h?
> That relies on having slab_cache be in the same location in struct
> page as slub_cache.  Maybe something like this?
>
>         page = virt_to_head_page(x);
> #ifdef CONFIG_SLUB
>         cachep = page->slub_cache;
> #else
>         cachep = page->slab_cache;
> #endif
>         if (slab_equal_or_root(cachep, s))
>                 return cachep;

Name the field "cache" instead of sl?b_cache?
