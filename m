Message-ID: <38745507.68EE54D2@idiom.com>
Date: Thu, 06 Jan 2000 11:40:39 +0300
From: Hans Reiser <reiser@idiom.com>
MIME-Version: 1.0
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3? (resending because
 my  ISP probably lost it)
References: <Pine.SCO.3.94.1000105153604.25431A-100000@tyne.london.sco.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tigran Aivazian <tigran@sco.COM>
Cc: "Peter J. Braam" <braam@cs.cmu.edu>, Andrea Arcangeli <andrea@suse.de>, "William J. Earl" <wje@cthulhu.engr.sgi.com>, Tan Pong Heng <pongheng@starnet.gov.sg>, "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, intermezzo-devel@stelias.com, simmonds@stelias.com
List-ID: <linux-mm.kvack.org>

Tigran Aivazian wrote:

> On Wed, 5 Jan 2000, Peter J. Braam wrote:
> > I think I mean joining.  What I need is:
> >
> >  braam starts trans
> >    does A
> >    calls reiser: hans starts
> >    does B
> >    hans commits; nothing goes to disk yet
> >    braam does C
> > braam commits/aborts ABC now go or don't
>
> no, that definitely looks like nesting to me.
>
> Tigran.

It looks like joining to me.  If it was nesting, you would be able to commit A
without comitting B.

Of course, if there is database literature defining nesting, and there probably
is, then I should be ignored here.
Perhaps the literature defines nesting as equivalent to what I call joining.

Hans

--
Get Linux (http://www.kernel.org) plus ReiserFS
 (http://devlinux.org/namesys).  If you sell an OS or
internet appliance, buy a port of ReiserFS!  If you
need customizations and industrial grade support, we sell them.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
