Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 4800C38C2D
	for <linux-mm@kvack.org>; Sun,  1 Jul 2001 23:59:53 -0300 (EST)
Date: Sun, 1 Jul 2001 23:59:52 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Removal of PG_marker scheme from 2.4.6-pre
In-Reply-To: <Pine.LNX.4.33.0107011943240.7587-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.33L.0107012358460.9312-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 1 Jul 2001, Linus Torvalds wrote:
> On Sun, 1 Jul 2001, Rik van Riel wrote:
> > > "me: undo page_launder() LRU changes, they have nasty side effects"
> > >
> > > Can you be more verbose about this ?
> >
> > I think this was fixed by the GFP_BUFFER vs. GFP_CAN_FS + GFP_CAN_IO
> > thing and Linus accidentally backed out the wrong code ;)
>
> You wish.
>
> Except it wasn't so.
>
> Follow the list, and read the emails that were cc'd to you.

I'll try to find them, but at the moment I'm on a slow
link (was at USENIX and am still a continent away from
where my email is) and I'm afraid I won't have too much
time for kernel stuff the next 3 weeks ;(

Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"


		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
