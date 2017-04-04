Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA23E6B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 08:02:46 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id n129so9534617pga.22
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 05:02:46 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p6si1522645pfj.42.2017.04.04.05.02.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 05:02:45 -0700 (PDT)
Date: Tue, 4 Apr 2017 05:02:44 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm/mmap: Replace SHM_HUGE_MASK with MAP_HUGE_MASK inside
 mmap_pgoff
Message-ID: <20170404120244.GI30811@bombadil.infradead.org>
References: <20170404045635.616-1-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170404045635.616-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, bsingharora@gmail.com, akpm@linux-foundation.org

On Tue, Apr 04, 2017 at 10:26:35AM +0530, Anshuman Khandual wrote:
> The commit 091d0d55b286 ("shm: fix null pointer deref when userspace
> specifies invalid hugepage size") had replaced MAP_HUGE_MASK with
> SHM_HUGE_MASK. Though both of them contain the same numeric value of
> 0x3f, MAP_HUGE_MASK flag sounds more appropriate than the other one
> in the context. Hence change it back.
> 
> Acked-by: Balbir Singh <bsingharora@gmail.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

We had a more extensive version of this last week ...

https://lkml.org/lkml/2017/3/28/1005

I'm fine with this minor fix going in by itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
