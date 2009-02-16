Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8D86B003D
	for <linux-mm@kvack.org>; Sun, 15 Feb 2009 20:33:00 -0500 (EST)
Subject: Re: [PATCH] Export symbol ksize()
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20090216012110.GA13575@gondor.apana.org.au>
References: <Pine.LNX.4.64.0902101605070.20991@melkki.cs.Helsinki.FI>
	 <20090212104349.GA13859@gondor.apana.org.au>
	 <1234435521.28812.165.camel@penberg-laptop>
	 <20090212105034.GC13859@gondor.apana.org.au>
	 <1234454104.28812.175.camel@penberg-laptop>
	 <20090215133638.5ef517ac.akpm@linux-foundation.org>
	 <1234734194.5669.176.camel@calx>
	 <20090215135555.688ae1a3.akpm@linux-foundation.org>
	 <1234741781.5669.204.camel@calx>
	 <20090215170052.44ee8fd5.akpm@linux-foundation.org>
	 <20090216012110.GA13575@gondor.apana.org.au>
Content-Type: text/plain
Date: Sun, 15 Feb 2009 19:28:46 -0600
Message-Id: <1234747726.5669.215.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-crypto@vger.kernel.org, Geert.Uytterhoeven@sonycom.com
List-ID: <linux-mm.kvack.org>

On Mon, 2009-02-16 at 09:21 +0800, Herbert Xu wrote:
> On Sun, Feb 15, 2009 at 05:00:52PM -0800, Andrew Morton wrote:
> >
> > But kmem_cache_size() would tell you how much extra secret memory there
> > is available after the object?
> > 
> > How that gets along with redzoning is a bit of a mystery though.
> > 
> > The whole concept is quite hacky and nasty, isn't it?.  Does
> > networking/crypto actually show any gain from pulling this stunt?
> 
> I see no point in calling ksize on memory that's not kmalloced.
> So no there is nothing to be gained from having kmem_cache_ksize.
> 
> However, for kmalloced memory we're wasting hundreds of bytes
> for the standard 1500 byte allocation without ksize which means
> that we're doing reallocations (and sometimes copying) when it
> isn't necessary.

Yeah. That sucks. We should probably stick in an skb-friendly slab size
and see what happens on network benchmarks.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
