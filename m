Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7D3646B003D
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 08:11:17 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] Export symbol ksize()
Date: Fri, 13 Feb 2009 00:10:45 +1100
References: <1234272104-10211-1-git-send-email-kirill@shutemov.name> <1234435521.28812.165.camel@penberg-laptop> <20090212105034.GC13859@gondor.apana.org.au>
In-Reply-To: <20090212105034.GC13859@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902130010.46623.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-crypto@vger.kernel.org, Geert.Uytterhoeven@sonycom.com
List-ID: <linux-mm.kvack.org>

On Thursday 12 February 2009 21:50:34 Herbert Xu wrote:
> On Thu, Feb 12, 2009 at 12:45:21PM +0200, Pekka Enberg wrote:
> > Because the API was being widely abused in the nommu code, for example.
> > I'd rather not add it back for this special case which can be handled
> > otherwise.
>
> I'm sorry but that's like banning the use of heaters just because
> they can abused and cause fires.
>
> I think I've said this to you before but in networking we very much
> want to use ksize because the standard case of a 1500-byte packet
> has loads of extra room given by kmalloc which all goes to waste
> right now.

I'm not against the idea of exporting ksize. It is a fairly well
commented function.

I'd be up for nearly anything in the slab layer that speeds up
networking, to be honest ;)


> If we could use ksize then we can stuff loads of metadata in that
> space.

I would be interested to know how that goes. You always have this
circular issue that if a little more space helps significantly, then
maybe it is a good idea to explicitly ask for those bytes. Of course
that larger allocation is also likely to have some slack bytes.

So the benefit you get from using these slack bytes has to be larger
than the cost of using ksize, but smaller than the cost of explicitly
asking for more bytes at alloc time. Interesting...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
