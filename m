Subject: Re: 0-order allocation problem
References: <Pine.LNX.4.33.0108151304340.2714-100000@penguin.transmeta.com>
	<20010816082419Z16176-1232+379@humbolt.nl.linux.org>
	<20010816112631.N398@redhat.com>
	<20010816121237Z16445-1231+1188@humbolt.nl.linux.org>
	<m1itfoow4p.fsf@frodo.biederman.org> <20010816173733.Y398@redhat.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 16 Aug 2001 21:20:21 -0600
In-Reply-To: <20010816173733.Y398@redhat.com>
Message-ID: <m1ae0zpe2y.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Linus Torvalds <torvalds@transmeta.com>, Hugh Dickins <hugh@veritas.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On Thu, Aug 16, 2001 at 09:35:50AM -0600, Eric W. Biederman wrote:
> 
> > > > It needs to be a count, not a flag (consider multiple mlock() calls
> > > > from different processes, or multiple direct IO writeouts from the
> > > > same memory to disk.)  
> > > 
> > > Yes, the question is how to do this without adding a yet another field
> > > to struct page.
> > 
> > atomic_add(&page->count, 65536);
> 
> That only leaves 8 bits for the pinned references (some architectures
> limit atomic_t to 24 bits), and 16 bits for genuine references isn't
> enough for some pages such as the zero page.

O.k. So that angle is out, but the other suggested approach where
we scan the list of vmas will still work.  Question do you know if
this logic would need to apply to things like ext3 and the journalling
filesystems.  

If we can limit the logic for accounting to things we have absolutely
no control over, it might just be reasonable.  Otherwise it starts
looking very tricky.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
