Date: Tue, 27 Nov 2007 15:22:56 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/1] mm: Prevent dereferencing non-allocated per_cpu
 variables
In-Reply-To: <20071127152122.1d5fbce3.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0711271522050.6713@schroedinger.engr.sgi.com>
References: <20071127215052.090968000@sgi.com> <20071127215054.660250000@sgi.com>
 <20071127221628.GG24223@one.firstfloor.org> <20071127151241.038c146d.akpm@linux-foundation.org>
 <20071127152122.1d5fbce3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: andi@firstfloor.org, travis@sgi.com, ak@suse.de, pageexec@freemail.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 27 Nov 2007, Andrew Morton wrote:

> The prefetch however might still need some work - we can indeed do
> prefetch() against a not-possible CPU's memory here.  And I do recall that
> 4-5 years ago we did have a CPU (one of mine, iirc) which would oops when
> prefetching from a bad address.  I forget what the conclusion was on that
> matter.
> 
> If we do want to fix the prefetch-from-outer-space then we should be using
> cpu_isset(cpu, *cpumask) here rather than cpu_possible().

Generally the prefetch things have turned out to be not that useful. How 
about dropping the prefetch? I kept it because it was there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
