Date: Wed, 22 Mar 2000 18:32:22 +0100
From: Jamie Lokier <jamie.lokier@cern.ch>
Subject: Re: MADV_DONTNEED
Message-ID: <20000322183222.A7271@pcep-jamie.cern.ch>
References: <20000321022937.B4271@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003221125170.16476-100000@funky.monkey.org> <20000322171045.D2850@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000322171045.D2850@redhat.com>; from Stephen C. Tweedie on Wed, Mar 22, 2000 at 05:10:45PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> The requests I've seen from database vendors are specifically for
> function 1 above.  I'd expect that they could live with function 3 
> too, though --- perhaps the main reason they asked for 1 is that 
> this is what they are used to working with on some other systems 
> (I don't know offhand of anybody who implements 3: it seems an odd
> thing to want to do for shared pages, and is equivalent to 1 for 
> private mappings.)

For private file mappings, 1 and 3 are different.  1 reverts pages to
the underlying object.  3 as equivalent to writing zeros over the page.

It's only for /dev/zero mappings that they are the same.

Probably nobody implements 3, but some documentation suggests
otherwise.  Digital Unix:

   MADV_DONTNEED   Do not need these pages
                   The system will free any whole pages in the specified
                   region.  All modifications will be lost and any swapped
                   out pages will be discarded.  Subsequent access to the
                   region will result in a zero-fill-on-demand fault
                                           ~~~~~~~~~~~~~~~~~~~
                   as though it is being accessed for the first time.
                   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                   Reserved swap space is not affected by this call.

Clearly for non-anonymous mappings, the two underlined phrases
contradict one another.  Does MADV_DONTNEED on DU zero pages in private
file mappings, or does it revert to the original file pages?

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
