Date: Sat, 10 Mar 2007 22:49:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [SLUB 0/3] SLUB: The unqueued slab allocator V5
Message-Id: <20070310224946.f9385917.akpm@linux-foundation.org>
In-Reply-To: <20070311021009.19963.11893.sendpatchset@schroedinger.engr.sgi.com>
References: <20070311021009.19963.11893.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

Is this safe to think about applying yet?

We lost the leak detector feature.

It might be nice to create synonyms for PageActive, PageReferenced and
PageError, to make things clearer in the slub core.   At the expense of
making things less clear globally.  Am unsure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
