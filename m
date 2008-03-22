Date: Sat, 22 Mar 2008 11:40:43 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [00/14] Virtual Compound Page Support V3
Message-ID: <20080322114043.17833ab4@laptopd505.fenrus.org>
In-Reply-To: <20080321061703.921169367@sgi.com>
References: <20080321061703.921169367@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Mar 2008 23:17:03 -0700
Christoph Lameter <clameter@sgi.com> wrote:

> Allocations of larger pages are not reliable in Linux. If larger
> pages have to be allocated then one faces various choices of allowing
> graceful fallback or using vmalloc with a performance penalty due
> to the use of a page table. Virtual Compound pages are
> a simple solution out of this dilemma.


can you document the drawback of large, frequent vmalloc() allocations at least?
On 32 bit x86, the effective vmalloc space is 64Mb or so (after various PCI bars are ioremaped),
so if this type of allocation is used for a "scales with nr of ABC" where "ABC" is workload dependent,
there's a rather abrupt upper limit to this.
Not saying that that is a flaw of your patch, just pointing out that we should discourage usage of 
the "scales with nr of ABC" (for example "one for each thread") kind of things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
