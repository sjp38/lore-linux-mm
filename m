Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: 0-order allocation problem
Date: Thu, 16 Aug 2001 14:18:56 +0200
References: <Pine.LNX.4.33.0108151304340.2714-100000@penguin.transmeta.com> <20010816082419Z16176-1232+379@humbolt.nl.linux.org> <20010816112631.N398@redhat.com>
In-Reply-To: <20010816112631.N398@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010816121237Z16445-1231+1188@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Hugh Dickins <hugh@veritas.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On August 16, 2001 12:26 pm, Stephen C. Tweedie wrote:
> Hi,
> 
> On Thu, Aug 16, 2001 at 10:30:35AM +0200, Daniel Phillips wrote:
> 
> > because the use count is overloaded.  So how about adding a PG_pinned
> > flag, and users need to set it for any page they intend to pin.
> 
> It needs to be a count, not a flag (consider multiple mlock() calls
> from different processes, or multiple direct IO writeouts from the
> same memory to disk.)  

Yes, the question is how to do this without adding a yet another field
to struct page.

> But yes, being able to distinguish freeable from unfreeable references
> to a page would be very useful, especially if we want to support very
> large memory allocations dynamically for things like i86 PSE 2MB/4MB
> page tables.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
