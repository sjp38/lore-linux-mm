Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C18A06B00A1
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 09:47:33 -0400 (EDT)
Date: Wed, 20 Oct 2010 08:47:30 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
In-Reply-To: <alpine.DEB.2.00.1010191337370.20631@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1010200846130.23134@router.home>
References: <20101005185725.088808842@linux.com> <alpine.DEB.2.00.1010191337370.20631@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Oct 2010, David Rientjes wrote:

> Overall, the results are _much_ better than the vanilla slub allocator
> that I frequently saw ~20% regressions with the TCP_RR netperf benchmark
> on a couple of my machines with larger cpu counts.  However, there still
> is a significant performance degradation compared to slab.

It seems that the memory leak is still present. This likely skews the
results. Thought I had it fixed. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
