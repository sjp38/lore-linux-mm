Date: Thu, 16 Aug 2001 17:37:33 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: 0-order allocation problem
Message-ID: <20010816173733.Y398@redhat.com>
References: <Pine.LNX.4.33.0108151304340.2714-100000@penguin.transmeta.com> <20010816082419Z16176-1232+379@humbolt.nl.linux.org> <20010816112631.N398@redhat.com> <20010816121237Z16445-1231+1188@humbolt.nl.linux.org> <m1itfoow4p.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1itfoow4p.fsf@frodo.biederman.org>; from ebiederm@xmission.com on Thu, Aug 16, 2001 at 09:35:50AM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Hugh Dickins <hugh@veritas.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Aug 16, 2001 at 09:35:50AM -0600, Eric W. Biederman wrote:

> > > It needs to be a count, not a flag (consider multiple mlock() calls
> > > from different processes, or multiple direct IO writeouts from the
> > > same memory to disk.)  
> > 
> > Yes, the question is how to do this without adding a yet another field
> > to struct page.
> 
> atomic_add(&page->count, 65536);

That only leaves 8 bits for the pinned references (some architectures
limit atomic_t to 24 bits), and 16 bits for genuine references isn't
enough for some pages such as the zero page.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
