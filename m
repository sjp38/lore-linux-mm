Date: Mon, 2 Oct 2000 15:24:39 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: TODO list for new VM  (oct 2000)
In-Reply-To: <Pine.LNX.4.10.10010021117540.828-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0010021524140.22539-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.redhat.com, linux-mm@kvack.org, Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Linus Torvalds wrote:

> Why do you apparently ignore the fact that page-out write-back
> performance is horribly crappy because it always starts out
> doing synchronous writes?

Because it is fixed in the patch I mailed yesterday?

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
