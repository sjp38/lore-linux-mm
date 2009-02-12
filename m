Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0535D6B003D
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 10:55:07 -0500 (EST)
Subject: Re: [PATCH] Export symbol ksize()
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090212105034.GC13859@gondor.apana.org.au>
References: <1234272104-10211-1-git-send-email-kirill@shutemov.name>
	 <84144f020902100535i4d626a9fj8cbb305120cf332a@mail.gmail.com>
	 <20090210134651.GA5115@epbyminw8406h.minsk.epam.com>
	 <Pine.LNX.4.64.0902101605070.20991@melkki.cs.Helsinki.FI>
	 <20090212104349.GA13859@gondor.apana.org.au>
	 <1234435521.28812.165.camel@penberg-laptop>
	 <20090212105034.GC13859@gondor.apana.org.au>
Date: Thu, 12 Feb 2009 17:55:04 +0200
Message-Id: <1234454104.28812.175.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-crypto@vger.kernel.org, Geert.Uytterhoeven@sonycom.com
List-ID: <linux-mm.kvack.org>

On Thu, Feb 12, 2009 at 12:45:21PM +0200, Pekka Enberg wrote:
> > 
> > Because the API was being widely abused in the nommu code, for example.
> > I'd rather not add it back for this special case which can be handled
> > otherwise.

On Thu, 2009-02-12 at 18:50 +0800, Herbert Xu wrote:
> I'm sorry but that's like banning the use of heaters just because
> they can abused and cause fires.
> 
> I think I've said this to you before but in networking we very much
> want to use ksize because the standard case of a 1500-byte packet
> has loads of extra room given by kmalloc which all goes to waste
> right now.
> 
> If we could use ksize then we can stuff loads of metadata in that
> space.

OK, fair enough, I applied Kirill's patch. Thanks.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
