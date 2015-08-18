Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 338906B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 20:43:15 -0400 (EDT)
Received: by pawq9 with SMTP id q9so21842595paw.3
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 17:43:15 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com. [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id p5si27136902par.165.2015.08.17.17.43.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Aug 2015 17:43:14 -0700 (PDT)
Received: by pdbmi9 with SMTP id mi9so20788131pdb.3
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 17:43:14 -0700 (PDT)
Date: Mon, 17 Aug 2015 17:43:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCHv2 1/4] mm: drop page->slab_page
In-Reply-To: <1439824145-25397-2-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.10.1508171742540.5527@chino.kir.corp.google.com>
References: <1439824145-25397-1-git-send-email-kirill.shutemov@linux.intel.com> <1439824145-25397-2-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andi Kleen <ak@linux.intel.com>, Christoph Lameter <cl@linux.com>

On Mon, 17 Aug 2015, Kirill A. Shutemov wrote:

> Since 8456a648cf44 ("slab: use struct page for slab management") nobody
> uses slab_page field in struct page.
> 
> Let's drop it.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andi Kleen <ak@linux.intel.com>
> Cc: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
