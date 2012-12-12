Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 552566B0062
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 15:15:33 -0500 (EST)
Date: Wed, 12 Dec 2012 21:15:29 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] mm: introduce numa_zero_pfn
Message-ID: <20121212201529.GD16230@one.firstfloor.org>
References: <1355331819-8728-1-git-send-email-js1304@gmail.com> <0000013b90beeb93-87f65a09-0cc3-419f-be26-5271148cb947-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013b90beeb93-87f65a09-0cc3-419f-be26-5271148cb947-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

> I would expect a processor to fetch the zero page cachelines from the l3
> cache from other sockets avoiding memory transactions altogether. The zero
> page is likely in use somewhere so no typically no memory accesses should
> occur in a system.

It depends on how effectively the workload uses the caches. If something
is a cache pig of the L3 cache, then even shareable cache lines may need
to be refetched regularly.

But if your workloads spends a significant part of its time reading
from zero page read only data there is something wrong with the workload.

I would do some data profiling first to really prove that is the case.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
