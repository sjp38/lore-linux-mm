Message-ID: <3B49AE09.CE19FBAC@mandrakesoft.com>
Date: Mon, 09 Jul 2001 09:13:45 -0400
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: [wip-PATCH] Re: Large PAGE_SIZE
References: <Pine.LNX.4.21.0107091210570.1187-100000@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Ben LaHaise <bcrl@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> 
> On Sun, 8 Jul 2001, Ben LaHaise wrote:
> >
> > Hmmm, interesting.  At present page cache sizes from PAGE_SIZE to
> > 8*PAGE_SIZE are working here.  Setting the shift to 4 or a 64KB page size
> > results in the SCSI driver blowing up on io completion.
> 
> I hit that limit too: I believe it comes from unsigned short b_size.

That limit's not a big deal.. the limits in the lower-level disk drivers
are what you start hitting...

-- 
Jeff Garzik      | A recent study has shown that too much soup
Building 1024    | can cause malaise in laboratory mice.
MandrakeSoft     |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
