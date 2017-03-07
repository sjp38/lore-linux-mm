Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 695016B0388
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 13:28:47 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v190so16122278pfb.5
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 10:28:47 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id w17si745235pge.203.2017.03.07.10.28.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 10:28:46 -0800 (PST)
Date: Tue, 7 Mar 2017 10:28:41 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm, vmalloc: use __GFP_HIGHMEM implicitly
Message-ID: <20170307182841.GS16328@bombadil.infradead.org>
References: <20170307141020.29107-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307141020.29107-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Cristopher Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Mar 07, 2017 at 03:10:20PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __vmalloc* allows users to provide gfp flags for the underlying
> allocation. This API is quite popular
> $ git grep "=[[:space:]]__vmalloc\|return[[:space:]]*__vmalloc" | wc -l
> 77
> 
> the only problem is that many people are not aware that they really want
> to give __GFP_HIGHMEM along with other flags because there is really no
> reason to consume precious lowmemory on CONFIG_HIGHMEM systems for pages
> which are mapped to the kernel vmalloc space. About half of users don't
> use this flag, though. This signals that we make the API unnecessarily
> too complex.
> 
> This patch simply uses __GFP_HIGHMEM implicitly when allocating pages to
> be mapped to the vmalloc space. Current users which add __GFP_HIGHMEM
> are simplified and drop the flag.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
