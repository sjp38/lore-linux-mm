Date: Mon, 15 May 2000 21:30:50 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] VM stable again?
In-Reply-To: <Pine.LNX.4.21.0005151608590.20410-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10005152122580.8896-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 May 2000, Rik van Riel wrote:

> I've thought about this but it doesn't seem worth the extra complexity
> to me. Just making sure that while our task is freeing pages nobody
> else will grab those pages without having also freed some pages seems
> to be enough to me.

actually wouldnt it be simpler to always call try_to_free_pages() when the
zone is low on memory? This will keep the pressure on the system to
recover from the low memory situation, and it reuses the low_on_memory
flag. The new free_before_allocate flag is a 'now we are really low on
memory' flag.

> Furthermore, the "SMP locality" you talk about will probably be
> completely overshadowed by the non-locality of the VM freeing code
> anyway...

But it would be a performance optimization for sure, a __free_pages() +
__alloc_pages() is saved - this can make a big difference if (a mostly
clean) pagecache is shrunk.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
