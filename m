Date: Sun, 1 Jul 2001 23:02:58 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Removal of PG_marker scheme from 2.4.6-pre
In-Reply-To: <Pine.LNX.4.21.0106301628570.3394-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.33L.0107012301460.19985-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 30 Jun 2001, Marcelo Tosatti wrote:

> In pre7:
>
> "me: undo page_launder() LRU changes, they have nasty side effects"
>
> Can you be more verbose about this ?

I think this was fixed by the GFP_BUFFER vs. GFP_CAN_FS + GFP_CAN_IO
thing and Linus accidentally backed out the wrong code ;)

cheers,
Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
