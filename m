Date: Tue, 15 Aug 2000 15:58:47 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Syncing the page cache, take 2
In-Reply-To: <20000815194635.H12218@redhat.com>
Message-ID: <Pine.LNX.4.21.0008151557040.2466-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Daniel Phillips <daniel.phillips@innominate.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Aug 2000, Stephen C. Tweedie wrote:

> Correct.  We have plans to change this in 2.5, basically by
> removing the VM's privileged knowledge about the buffer cache
> and making the buffer operations (write-back, unmap etc.) into
> special cases of generic address-space operations.  For 2.4,
> it's really to late to do anything about this.

Stephen,

please take a look at my VM patch at http://www.surriel.com/patches/
(either the -test4 or the -test7-pre4 one).

If you look closely at mm/vmscan.c::page_launder(), you'll see
that we should be able to add the flush callback with only about
5 to 10 lines of changed code ...

(and even more ... we just about *need* the flush callback when
we're running in a multi-queue VM)

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
