Date: Wed, 17 Aug 2005 17:47:20 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: pagefault scalability patches
Message-Id: <20050817174720.47ac351f.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.62.0508171656080.19528@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org>
	<Pine.LNX.4.58.0508171529530.3553@g5.osdl.org>
	<Pine.LNX.4.62.0508171550001.19273@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0508171559350.3553@g5.osdl.org>
	<Pine.LNX.4.62.0508171603240.19363@schroedinger.engr.sgi.com>
	<20050817163030.15e819dd.akpm@osdl.org>
	<Pine.LNX.4.62.0508171631160.19528@schroedinger.engr.sgi.com>
	<20050817164456.77e8b85e.akpm@osdl.org>
	<17155.52686.309135.906824@wombat.chubb.wattle.id.au>
	<Pine.LNX.4.62.0508171656080.19528@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: peterc@gelato.unsw.edu.au, torvalds@osdl.org, hugh@veritas.com, piggin@cyberone.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> On Thu, 18 Aug 2005, Peter Chubb wrote:
> 
> > >>>>> "Andrew" == Andrew Morton <akpm@osdl.org> writes:
> > 
> > Andrew> The decreases in system CPU time for the single-threaded case
> > Andrew> are extraordinarily high.  
> > 
> > Are the sizes of the test the same?  The unpatched version says 16G,
> > the patched one 4G --- with a quarter the memory size I'd expect less
> > than a quarter of the overhead...
> 
> Yup I screwed up.
> 
> Patched:
> 
>  Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
>  16   3    1    0.859s     64.994s  65.084s 47768.542  47771.664

Versus:

> Unpatched:
>
>  Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
>  16   3    1    0.757s     62.772s  63.052s 49515.393  49522.112

It got slower?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
