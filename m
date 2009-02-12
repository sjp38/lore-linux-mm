Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1196B0098
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 18:37:29 -0500 (EST)
Subject: Re: [PATCH] Export symbol ksize()
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20090212230934.GA21609@gondor.apana.org.au>
References: <1234272104-10211-1-git-send-email-kirill@shutemov.name>
	 <1234435521.28812.165.camel@penberg-laptop>
	 <20090212105034.GC13859@gondor.apana.org.au>
	 <200902130010.46623.nickpiggin@yahoo.com.au>
	 <20090212230934.GA21609@gondor.apana.org.au>
Content-Type: text/plain
Date: Thu, 12 Feb 2009 17:37:01 -0600
Message-Id: <1234481821.3152.27.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Pekka Enberg <penberg@cs.helsinki.fi>, "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-crypto@vger.kernel.org, Geert.Uytterhoeven@sonycom.com
List-ID: <linux-mm.kvack.org>

On Fri, 2009-02-13 at 07:09 +0800, Herbert Xu wrote:
> On Fri, Feb 13, 2009 at 12:10:45AM +1100, Nick Piggin wrote:
> > 
> > I would be interested to know how that goes. You always have this
> > circular issue that if a little more space helps significantly, then
> > maybe it is a good idea to explicitly ask for those bytes. Of course
> > that larger allocation is also likely to have some slack bytes.
> 
> Well, the thing is we don't know apriori whether we need the
> extra space.  The idea is to use the extra space if available
> to avoid reallocation when we hit things like IPsec.

I'm not entirely convinced by this argument. If you're concerned about
space rather than performance, then you want an allocator that doesn't
waste space in the first place and you don't try to do "sub-allocations"
by hand. If you're concerned about performance, you instead optimize
your allocator to be as fast as possible and again avoid conditional
branches for sub-allocations.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
