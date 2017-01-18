Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7071D6B0038
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 16:34:58 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id d134so33038207pfd.0
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 13:34:58 -0800 (PST)
Received: from mail-pg0-x22c.google.com (mail-pg0-x22c.google.com. [2607:f8b0:400e:c05::22c])
        by mx.google.com with ESMTPS id f35si1354443plh.192.2017.01.18.13.34.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 13:34:57 -0800 (PST)
Received: by mail-pg0-x22c.google.com with SMTP id 194so7568882pgd.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 13:34:57 -0800 (PST)
Date: Wed, 18 Jan 2017 13:34:55 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/mempolicy.c: do not put mempolicy before using its
 nodemask
In-Reply-To: <20170118141124.8345-1-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1701181331030.133727@chino.kir.corp.google.com>
References: <20170118141124.8345-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, 18 Jan 2017, Vlastimil Babka wrote:

> Since commit be97a41b291e ("mm/mempolicy.c: merge alloc_hugepage_vma to
> alloc_pages_vma") alloc_pages_vma() can potentially free a mempolicy by
> mpol_cond_put() before accessing the embedded nodemask by
> __alloc_pages_nodemask(). The commit log says it's so "we can use a single
> exit path within the function" but that's clearly wrong. We can still do that
> when doing mpol_cond_put() after the allocation attempt.
> 
> Make sure the mempolicy is not freed prematurely, otherwise
> __alloc_pages_nodemask() can end up using a bogus nodemask, which could lead
> e.g. to premature OOM.
> 
> Fixes: be97a41b291e ("mm/mempolicy.c: merge alloc_hugepage_vma to alloc_pages_vma")
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: stable@vger.kernel.org
> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

I think this deserves Cc: stable@vger.kernel.org [4.0+]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
