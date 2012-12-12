Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id B60AC6B005D
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 15:12:11 -0500 (EST)
Date: Wed, 12 Dec 2012 20:12:09 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: introduce numa_zero_pfn
In-Reply-To: <1355331819-8728-1-git-send-email-js1304@gmail.com>
Message-ID: <0000013b90beeb93-87f65a09-0cc3-419f-be26-5271148cb947-000000@email.amazonses.com>
References: <1355331819-8728-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi@firstfloor.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, 13 Dec 2012, Joonsoo Kim wrote:

> Currently, we use just *one* zero page regardless of user process' node.
> When user process read zero page, at first, cpu should load this
> to cpu cache. If node of cpu is not same as node of zero page, loading
> takes long time. If we make zero pages for each nodes and use them
> adequetly, we can reduce this overhead.

Are you sure about the loading taking a long time?

I would expect a processor to fetch the zero page cachelines from the l3
cache from other sockets avoiding memory transactions altogether. The zero
page is likely in use somewhere so no typically no memory accesses should
occur in a system.

Fetching from the l3 cache out of another socket is faster than
fetching from local memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
