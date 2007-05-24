Date: Thu, 24 May 2007 05:15:48 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070524031548.GA14349@wotan.suse.de>
References: <20070523183224.GD11115@waste.org> <Pine.LNX.4.64.0705231208380.21222@schroedinger.engr.sgi.com> <20070523195824.GF11115@waste.org> <Pine.LNX.4.64.0705231300070.21541@schroedinger.engr.sgi.com> <20070523210612.GI11115@waste.org> <Pine.LNX.4.64.0705231524140.22666@schroedinger.engr.sgi.com> <20070523224206.GN11115@waste.org> <Pine.LNX.4.64.0705231544310.22857@schroedinger.engr.sgi.com> <20070524020530.GA13694@wotan.suse.de> <Pine.LNX.4.64.0705231945450.23981@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705231945450.23981@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 07:49:50PM -0700, Christoph Lameter wrote:
> Here is what I got trying to trim down SLUB on x84_64 (UP config)
> 
> Full:
> 
>    text    data     bss     dec     hex filename
>   25928   11351     256   37535    929f mm/slub.o
> 
> !CONFIG_SLUB_DEBUG + patch below
> 
>    text    data     bss     dec     hex filename
>    8639    4735     224   13598    351e mm/slub.o
> 
> SLOB
> 
>    text    data     bss     dec     hex filename
>    4206      96       0    4302    10ce mm/slob.o
> 
> So we can get down to about double the text size. Data is of course an 
> issue. Other 64 bit platforms bloat the code significantly.
> 
> Interesting that inlining some functions actually saves memory.
> 
> SLUB embedded: Reduce memory use II

After boot test, this has 760K free.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
