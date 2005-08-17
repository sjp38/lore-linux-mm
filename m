Date: Wed, 17 Aug 2005 16:44:56 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: pagefault scalability patches
Message-Id: <20050817164456.77e8b85e.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.62.0508171631160.19528@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org>
	<Pine.LNX.4.58.0508171529530.3553@g5.osdl.org>
	<Pine.LNX.4.62.0508171550001.19273@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0508171559350.3553@g5.osdl.org>
	<Pine.LNX.4.62.0508171603240.19363@schroedinger.engr.sgi.com>
	<20050817163030.15e819dd.akpm@osdl.org>
	<Pine.LNX.4.62.0508171631160.19528@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: torvalds@osdl.org, hugh@veritas.com, piggin@cyberone.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> On Wed, 17 Aug 2005, Andrew Morton wrote:
> 
> > With what workload, on what hardware?
> 
> This is the page fault scalability test that I posted last year with the 
> first edition of this patchset. Hardware is Itanium with 256 nodes 
> otherwise I would not have been able to test up to 512 processors.

We forget things easily - please don't expect us to remember what that test
did.

What did it do?

The decreases in system CPU time for the single-threaded case are
extraordinarily high.  What's going on?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
