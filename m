Date: Sat, 30 Jun 2001 21:35:06 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Removal of PG_marker scheme from 2.4.6-pre
In-Reply-To: <Pine.LNX.4.21.0106301628570.3394-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.33.0106302134050.1092-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 30 Jun 2001, Marcelo Tosatti wrote:
>
> In pre7:
>
> "me: undo page_launder() LRU changes, they have nasty side effects"
>
> Can you be more verbose about this ?

See the thread about 2.4.5-ac13+ (and my pre3+) basically becoming
unusable for longish times (temporarily locking up) on linux-kernel. It
was due to these changes.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
