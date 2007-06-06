Date: Wed, 6 Jun 2007 11:36:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Use ilog2 instead of series of constant comparisons.
In-Reply-To: <20070606100817.7af24b74.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0706061053290.11553@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705211250410.27950@schroedinger.engr.sgi.com>
 <20070606100817.7af24b74.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 6 Jun 2007, Andrew Morton wrote:

> This caused test.kernel.org's power4 build to blow up:
> 
> http://test.kernel.org/abat/93315/debug/test.log.0
> 
> fs/built-in.o(.text+0x148420): In function `.CalcNTLMv2_partial_mac_key':
> : undefined reference to `.____ilog2_NaN'

Hmmm... Weird message that does not allow too much analysis.
The __ilog2_NaN comes about if 0 or a negative number is passed to ilog. 
There is no way for that to happen since we check for KMALLOC_MIN_SIZE 
and KMALLOC_MAX_SIZE in kmalloc_index() and an unsigned value is used.

There is also nothing special in CalcNTLMv2_partial_mac_key(). Two 
kmallocs of 33 bytes and 132 bytes each.

Buggy compiler (too much stress on constant folding)? Or hardware? Can we 
rerun the test?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
