Date: Wed, 17 Aug 2005 16:58:49 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: pagefault scalability patches
In-Reply-To: <17155.52686.309135.906824@wombat.chubb.wattle.id.au>
Message-ID: <Pine.LNX.4.62.0508171656080.19528@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <Pine.LNX.4.58.0508171529530.3553@g5.osdl.org>
 <Pine.LNX.4.62.0508171550001.19273@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0508171559350.3553@g5.osdl.org>
 <Pine.LNX.4.62.0508171603240.19363@schroedinger.engr.sgi.com>
 <20050817163030.15e819dd.akpm@osdl.org> <Pine.LNX.4.62.0508171631160.19528@schroedinger.engr.sgi.com>
 <20050817164456.77e8b85e.akpm@osdl.org> <17155.52686.309135.906824@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, hugh@veritas.com, piggin@cyberone.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Aug 2005, Peter Chubb wrote:

> >>>>> "Andrew" == Andrew Morton <akpm@osdl.org> writes:
> 
> Andrew> The decreases in system CPU time for the single-threaded case
> Andrew> are extraordinarily high.  
> 
> Are the sizes of the test the same?  The unpatched version says 16G,
> the patched one 4G --- with a quarter the memory size I'd expect less
> than a quarter of the overhead...

Yup I screwed up.

Patched:

 Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
 16   3    1    0.859s     64.994s  65.084s 47768.542  47771.664
 16   3    2    0.682s     63.165s  33.097s 49269.255  92591.334
 16   3    4    0.632s     52.805s  17.061s 58866.320 178579.491
 16   3    8    0.683s     44.233s   8.074s 70034.218 359660.206
 16   3   16    0.666s     82.785s   8.052s 37694.972 368802.163
 16   3   32    1.301s    172.066s   8.085s 18144.775 355252.190
 16   3   64    4.958s    364.566s   9.054s  8512.883 329495.174
 16   3  128   20.006s    860.666s  11.000s  3571.958 285801.678
 16   3  256   12.773s    546.095s   6.071s  5628.745 468417.083
 16   3  512   14.547s    253.782s   3.053s 11723.346 889858.164

Tool used to measure this is at 
http://marc.theaimsgroup.com/?l=linux-kernel&m=109257807215046&w=2

The code for the test program follows the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
