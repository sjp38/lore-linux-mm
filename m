Date: Thu, 16 Aug 2001 11:26:31 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: 0-order allocation problem
Message-ID: <20010816112631.N398@redhat.com>
References: <Pine.LNX.4.33.0108151304340.2714-100000@penguin.transmeta.com> <20010816082419Z16176-1232+379@humbolt.nl.linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010816082419Z16176-1232+379@humbolt.nl.linux.org>; from phillips@bonn-fries.net on Thu, Aug 16, 2001 at 10:30:35AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, Hugh Dickins <hugh@veritas.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Aug 16, 2001 at 10:30:35AM +0200, Daniel Phillips wrote:

> because the use count is overloaded.  So how about adding a PG_pinned
> flag, and users need to set it for any page they intend to pin.

It needs to be a count, not a flag (consider multiple mlock() calls
from different processes, or multiple direct IO writeouts from the
same memory to disk.)  

But yes, being able to distinguish freeable from unfreeable references
to a page would be very useful, especially if we want to support very
large memory allocations dynamically for things like i86 PSE 2MB/4MB
page tables.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
