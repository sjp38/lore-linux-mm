Message-ID: <3D33371D.6003AAAE@zip.com.au>
Date: Mon, 15 Jul 2002 13:57:01 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Optimize away pte_chains for single mappings
References: <Pine.LNX.4.44L.0207151333530.12241-100000@imladris.surriel.com> <E17U8vA-0003ca-00@starship>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Rik van Riel <riel@conectiva.com.br>, Matti Aarnio <matti.aarnio@zmailer.org>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Daniel Phillips wrote:
> 
> On Monday 15 July 2002 18:34, Rik van Riel wrote:
> > On Mon, 15 Jul 2002, Daniel Phillips wrote:
> >
> > > None of these cases apply, the low bit is always masked off before being
> > > used as a pointer.
> >
> > Too ugly to live.
> 
> That's a nonargument.  I presume you weren't able to think of a
> substantive reason.

How about "Linus will roast our nuts if we do that"?

Plus accessing the same storage with both atomic and non-atomic
ops may be a problem on some hardware.

Let's wait until we run out of page flags first...

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
