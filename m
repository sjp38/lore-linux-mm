Date: Mon, 2 Oct 2000 12:43:25 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.0-test9-pre8 + Rik Riel's latest VM patch -- Athlon system
 lockup
In-Reply-To: <39D845E1.BFB8AC74@speakeasy.org>
Message-ID: <Pine.LNX.4.21.0010021242210.22539-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miles Lane <miles@speakeasy.org>
Cc: MM mailing list <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Miles Lane wrote:

> I was stress testing this machine harder than I ever have
> before. I saw my load average reach as high as 19.2 and the CPU
> was pegged for about half an hour.  I was performing
> simultaneous intensive reads and writes on the internal EIDE
> drive and and external ORB drive accessed over a USB connection.  
> In addition, I was running x11perf.  I had launched enough
> programs to consume all my swap space and free physical memory
> was pegged, too.

As was mentioned in my email, out of memory handling isn't
in this patch yet ;)

If the current feature set proves stable, I'll add out of
memory handling.

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
