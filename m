Date: Thu, 29 Jun 2000 11:52:14 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: kmap_kiobuf()
Message-ID: <20000629115214.B3914@redhat.com>
References: <11270.962206915@cygnus.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <11270.962206915@cygnus.co.uk>; from dwmw2@infradead.org on Wed, Jun 28, 2000 at 04:41:55PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, sct@redhat.com, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 28, 2000 at 04:41:55PM +0100, David Woodhouse wrote:

> I think it would be useful to provide a function which can be used to 
> obtain a virtually-contiguous VM mapping of the pages of an iobuf.

Perhaps, but I really would rather resist this.  The whole point of
kiobufs is to let you deal cleanly with thinks which are unaligned by
doing page lookups.  They are specifically intended to _avoid_ nasty
VM tricks.  

Adding kiobuf support for things like memcpy_to/from_kiobuf is
something I will do, but kiobufs are there to help get people out of
the mindset that all buffers are virtually contiguous in the first
place!  

It would be fairly easy to add kiobuf support for this, but it would
make it harder to get the diffs past Linus (who really wants vmalloc
to go away as much as possible).

I'm open to arguments, but "I coded this way in the past and I'd
rather the kernel did ugly things to let me keep coding this way in
the future" isn't the sort of reasoning that helps me to get new
functionality past Linus's sanity filters.  :-)

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
