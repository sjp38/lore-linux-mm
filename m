Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] Optimize away pte_chains for single mappings
Date: Tue, 16 Jul 2002 06:50:56 +0200
References: <Pine.LNX.4.44L.0207151333530.12241-100000@imladris.surriel.com> <E17U8vA-0003ca-00@starship> <3D33371D.6003AAAE@zip.com.au>
In-Reply-To: <3D33371D.6003AAAE@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17UKIa-0003hA-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, Matti Aarnio <matti.aarnio@zmailer.org>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 15 July 2002 22:57, Andrew Morton wrote:
> Daniel Phillips wrote:
> > On Monday 15 July 2002 18:34, Rik van Riel wrote:
> > > On Mon, 15 Jul 2002, Daniel Phillips wrote:
> > >
> > > > None of these cases apply, the low bit is always masked off before being
> > > > used as a pointer.
> > >
> > > Too ugly to live.
> > 
> > That's a nonargument.  I presume you weren't able to think of a
> > substantive reason.
> 
> How about "Linus will roast our nuts if we do that"?

Unless someone can come up with a rational argument, I'd be forced to conclude
that Linus is superstitious.

> Plus accessing the same storage with both atomic and non-atomic
> ops may be a problem on some hardware.

Qu'est-ce que ca veux dire?  We're protected under the pte_chain lock are we
not?

> Let's wait until we run out of page flags first...

Sure, I intend to lay claim to six of them in due course, that would leave a
mere eight for posterity.

Then there is the method I proposed for saving 8 bytes per pte_chain with
the help of an overloaded pointer.  In what way does that not turn the ugly
duckling into a beautiful swan?

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
