Date: Thu, 6 Jun 2002 14:47:41 +1000 (EST)
From: Michael Chapman <mchapman@beren.hn.org>
Reply-To: Michael Chapman <mchapman@student.usyd.edu.au>
Subject: Re: Oops in pte_chain_alloc (rmap 12h applied to vanilla 2.4.18)
 (fwd)
In-Reply-To: <20020606003935.A29285@redhat.com>
Message-ID: <Pine.LNX.4.44.0206061441160.1337-100000@beren.hn.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Jonathan Morton <chromi@cyberspace.org>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 Jun 2002, Benjamin LaHaise wrote:
> On Thu, Jun 06, 2002 at 02:29:18PM +1000, Michael Chapman wrote:
> > On Wed, 5 Jun 2002, Jonathan Morton wrote:
> > > >I compiled this kernel with gcc 2.96.
> > > 
> > > I understood you weren't supposed to do that.  Try 2.95.3.
> > 
> > OK, I've now tried that. It still crashes on the same line of code.
> 
> This looks like a memory corruption footprint:
> 
> Jun  3 09:58:02 beren kernel: Unable to handle kernel paging request at virtual address 14000000
> 
> Have you tried running memtest86 on the machine?  A few bugzilla reports 
> have turned up with similar footprints that have all turned out to be 
> bad ram, so it is worth investigating.

Yes I have. I ran memtest (version 3.0) for over 12 hours a couple of days 
ago. Not one problem reported.

> 		-ben

Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
