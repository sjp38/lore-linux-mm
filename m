Subject: Re: Yet another bogus piece of do_try_to_free_pages()
References: <Pine.LNX.4.21.0101100425150.7931-100000@freak.distro.conectiva>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 11 Jan 2001 01:11:39 +0100
In-Reply-To: Marcelo Tosatti's message of "Wed, 10 Jan 2001 04:39:28 -0200 (BRST)"
Message-ID: <87r92bq75w.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo@conectiva.com.br> writes:

> On Tue, 9 Jan 2001, Linus Torvalds wrote:
> 
> > I suspect that the proper fix is something more along the lines of what we
> > did to bdflush: get rid of the notion of waiting synchronously from
> > bdflush, and instead do the work yourself. 
> 
> Agreed. 
> 
> Without blocking on sync IO, kswapd can keep aging pages and moving
> them to the inactive lists. 
> 
> The following patch changes some stuff we've discussed before (the
> kmem_cache_reap and maxtry thingies) and it also removes the kswapd
> sleeping scheme.
> 
> I haven't tested it yet, though I'll do it tomorrow.
> 

I have tested it for you and results are great. On some tests I got
20% to 30% better results which is amazing. I'll do some more tests
but I would vote for this to get in immediately. Yes, it's *so* good.

Great work Marcelo!
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
