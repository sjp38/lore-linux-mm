Date: Mon, 9 Oct 2000 18:26:01 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010092325070.9803-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0010091825370.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Ingo Molnar wrote:
> On Mon, 9 Oct 2000, Alan Cox wrote:
> 
> > Lets kill a 6 week long typical background compute job because
> > netscape exploded (and yes netscape has a child process)
> 
> in the paragraph you didnt quote i pointed this out and
> suggested adding all parent's badness value to children as well
> - so we'd end up killing netscape.

Would this complexity /really/ be worth it for the twice-yearly
OOM situation?

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
