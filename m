From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
Date: Wed, 10 Aug 2005 05:19:13 +1000
References: <42F57FCA.9040805@yahoo.com.au> <1123577509.30257.173.camel@gaston> <42F87C24.4080000@yahoo.com.au>
In-Reply-To: <42F87C24.4080000@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508100519.14462.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>

On Tuesday 09 August 2005 19:49, Nick Piggin wrote:
> Benjamin Herrenschmidt wrote:
> > I have no problem keeping PG_reserved for that, and _ONLY_ for that.
> > (though i'd rather see it renamed then). I'm just afraid by doing so,
> > some drivers will jump in the gap and abuse it again...
>
> Sure it would be renamed (better yet may be a slower page_is_valid()
> that doesn't need to use a flag).

Right!  This is the correct time to wrap all remaining users (that use the 
newly-mandated valid page sense) in an inline or macro.  And this patch set 
should change the flag name, because it quietly changes the rules.  I think 
you need a 3/3 that drops the other shoe.

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
