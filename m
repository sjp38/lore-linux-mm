Date: Wed, 5 Jan 2000 15:37:36 +0000 (GMT)
From: Tigran Aivazian <tigran@sco.COM>
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3? (resending because my  ISP probably lost it)
In-Reply-To: <Pine.LNX.4.02.10001051020180.27314-100000@carissimi.coda.cs.cmu.edu>
Message-ID: <Pine.SCO.3.94.1000105153604.25431A-100000@tyne.london.sco.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Peter J. Braam" <braam@cs.cmu.edu>
Cc: Hans Reiser <reiser@idiom.com>, Andrea Arcangeli <andrea@suse.de>, "William J. Earl" <wje@cthulhu.engr.sgi.com>, Tan Pong Heng <pongheng@starnet.gov.sg>, "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, intermezzo-devel@stelias.com, simmonds@stelias.com
List-ID: <linux-mm.kvack.org>

On Wed, 5 Jan 2000, Peter J. Braam wrote:
> I think I mean joining.  What I need is:
>   
>  braam starts trans
>    does A
>    calls reiser: hans starts
>    does B
>    hans commits; nothing goes to disk yet
>    braam does C
> braam commits/aborts ABC now go or don't

no, that definitely looks like nesting to me.

Tigran.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
