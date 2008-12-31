Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A61406B00A9
	for <linux-mm@kvack.org>; Wed, 31 Dec 2008 17:53:44 -0500 (EST)
Date: Wed, 31 Dec 2008 16:53:28 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] cpuset,mm: fix allocating page cache/slab object on the
 unallowed node when memory spread is set
In-Reply-To: <20081230142805.3c6f78e3.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0812311648250.21443@quilx.com>
References: <49547B93.5090905@cn.fujitsu.com> <20081230142805.3c6f78e3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: miaox@cn.fujitsu.com, menage@google.com, penberg@cs.helsinki.fi, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Dec 2008, Andrew Morton wrote:

> d) How does slub handle this problem?

SLUB understands memory policies to apply to the pages from which
objects are acquired. MPOL_INTERLEAVE applies to the pages acquired
by the allocator not to individual objects acquired by the user of the
allocator from these pages.

With that point of view most of the memory policy handling can be pushed
into the page allocator.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
