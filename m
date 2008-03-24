Date: Mon, 24 Mar 2008 11:31:05 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [00/14] Virtual Compound Page Support V3
In-Reply-To: <20080322114043.17833ab4@laptopd505.fenrus.org>
Message-ID: <Pine.LNX.4.64.0803241129100.3002@schroedinger.engr.sgi.com>
References: <20080321061703.921169367@sgi.com> <20080322114043.17833ab4@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 22 Mar 2008, Arjan van de Ven wrote:

> can you document the drawback of large, frequent vmalloc() allocations at least?

Ok. Lets add some documentation about this issue and some other 
things. A similar suggestion was made by Kosaki-san.

> On 32 bit x86, the effective vmalloc space is 64Mb or so (after various PCI bars are ioremaped),
> so if this type of allocation is used for a "scales with nr of ABC" where "ABC" is workload dependent,
> there's a rather abrupt upper limit to this.
> Not saying that that is a flaw of your patch, just pointing out that we should discourage usage of 
> the "scales with nr of ABC" (for example "one for each thread") kind of things.

I better take out any patches that do large scale allocs then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
