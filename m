Message-ID: <3B49C0B3.4546B66B@mandrakesoft.com>
Date: Mon, 09 Jul 2001 10:33:23 -0400
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: [wip-PATCH] Re: Large PAGE_SIZE
References: <Pine.LNX.4.21.0107091426450.1282-100000@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Ben LaHaise <bcrl@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Mon, 9 Jul 2001, Jeff Garzik wrote:
> > Hugh Dickins wrote:
> > > On Sun, 8 Jul 2001, Ben LaHaise wrote:
> > > >
> > > > Hmmm, interesting.  At present page cache sizes from PAGE_SIZE to
> > > > 8*PAGE_SIZE are working here.  Setting the shift to 4 or a 64KB page size
> > > > results in the SCSI driver blowing up on io completion.
> > >
> > > I hit that limit too: I believe it comes from unsigned short b_size.
> >
> > That limit's not a big deal.. the limits in the lower-level disk drivers
> > are what you start hitting...
> 
> Examples?

16-bit size values in places like the SCSI mid layer.

> Linus believes it would be no more than a few buggy drivers which would
> impose such limits;

I cannot say "few" or "many", Ben knows better than I, but Linus is
correct...  there is no hard 64K limit, it is just bugs we must flush
out of drivers and layers.

-- 
Jeff Garzik      | A recent study has shown that too much soup
Building 1024    | can cause malaise in laboratory mice.
MandrakeSoft     |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
