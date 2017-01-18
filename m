Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C3B9A6B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 12:07:16 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 80so23985404pfy.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 09:07:16 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id c23si774257pli.184.2017.01.18.09.07.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 09:07:15 -0800 (PST)
Date: Wed, 18 Jan 2017 20:04:45 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] mm/mempolicy.c: do not put mempolicy before using its
 nodemask
Message-ID: <20170118170444.s4z5jqn57fqbnvnf@black.fi.intel.com>
References: <20170118141124.8345-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118141124.8345-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Jan 18, 2017 at 03:11:24PM +0100, Vlastimil Babka wrote:
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

Looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
