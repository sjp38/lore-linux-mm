Date: Thu, 18 Aug 2005 09:09:10 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: pagefault scalability patches
In-Reply-To: <20050817174720.47ac351f.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0508180904440.25799@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <Pine.LNX.4.58.0508171529530.3553@g5.osdl.org>
 <Pine.LNX.4.62.0508171550001.19273@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0508171559350.3553@g5.osdl.org>
 <Pine.LNX.4.62.0508171603240.19363@schroedinger.engr.sgi.com>
 <20050817163030.15e819dd.akpm@osdl.org> <Pine.LNX.4.62.0508171631160.19528@schroedinger.engr.sgi.com>
 <20050817164456.77e8b85e.akpm@osdl.org> <17155.52686.309135.906824@wombat.chubb.wattle.id.au>
 <Pine.LNX.4.62.0508171656080.19528@schroedinger.engr.sgi.com>
 <20050817174720.47ac351f.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: peterc@gelato.unsw.edu.au, torvalds@osdl.org, hugh@veritas.com, piggin@cyberone.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Aug 2005, Andrew Morton wrote:

> > Patched:
> > 
> >  Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
> >  16   3    1    0.859s     64.994s  65.084s 47768.542  47771.664
> 
> Versus:
> 
> > Unpatched:
> >
> >  Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
> >  16   3    1    0.757s     62.772s  63.052s 49515.393  49522.112
> 
> It got slower?

For that sample yes. There is a certain unpredictability coming with NUMA 
systems. Memory placement affects the tests. This in the margin of error.

Another test shows just the opposite:

unpatched:
 Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
 16   3    1    0.735s     64.074s  64.083s 48537.993  48519.120
 16   3    2    0.773s     94.774s  49.046s 32923.047  63588.898
 16   3    4    0.717s     87.110s  29.092s 35816.846 105117.121
 16   3    8    0.677s    136.768s  21.069s 22886.951 145008.228
 16   3   16    0.757s    288.464s  23.045s 10876.524 134128.797
 16   3   32   13.612s    297.150s  23.034s 10122.600 134723.354
 16   3   64   60.201s    318.414s  27.048s  8308.505 114470.017
 16   3  128  279.422s    322.942s  41.063s  5222.299  75562.812
 16   3  256  280.823s    146.732s  28.073s  7357.466 109486.455
 16   3  512  282.124s     77.636s  24.023s  8743.940 129787.460

patched:

 Gb Rep Threads   User      System     Wall flt/cpu/s fault/wsec
 16   3    1    0.702s     62.858s  63.056s 49491.809  49489.633
 16   3    2    0.734s     72.348s  38.004s 43043.199  82674.132
 16   3    4    0.718s     76.552s  25.012s 40710.056 125186.047
 16   3    8    0.782s     58.417s  12.020s 53137.972 257740.814
 16   3   16    1.534s     93.568s   9.092s 33077.207 316995.454
 16   3   32    3.297s    173.145s   9.078s 17828.534 321373.156
 16   3   64    9.001s    445.874s  11.064s  6915.569 270213.663
 16   3  128   27.157s   1500.321s  16.060s  2059.426 189481.849
 16   3  256   25.647s    762.183s   8.083s  3992.895 355973.645
 16   3  512   26.167s    407.595s   5.008s  7252.183 619054.581

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
