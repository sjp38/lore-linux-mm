Date: Sun, 1 Jul 2001 19:47:24 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Removal of PG_marker scheme from 2.4.6-pre
In-Reply-To: <Pine.LNX.4.33L.0107012301460.19985-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.33.0107011943240.7587-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 1 Jul 2001, Rik van Riel wrote:
> > "me: undo page_launder() LRU changes, they have nasty side effects"
> >
> > Can you be more verbose about this ?
>
> I think this was fixed by the GFP_BUFFER vs. GFP_CAN_FS + GFP_CAN_IO
> thing and Linus accidentally backed out the wrong code ;)

You wish.

Except it wasn't so.

Follow the list, and read the emails that were cc'd to you.

pre2 was fine, pre3 was not.

ac12 was fine, ac13 was not.

pre3 with the pre2 page_launder was fine.

There is no question about it. The patch that caused problems was the one
that was reversed. Please stop confusing the issue.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
