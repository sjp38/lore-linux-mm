Date: Mon, 2 Oct 2000 16:59:57 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <20001002215628.D21473@athlon.random>
Message-ID: <Pine.LNX.4.21.0010021658040.1067-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Andrea Arcangeli wrote:
> On Mon, Oct 02, 2000 at 04:35:43PM -0300, Rik van Riel wrote:
> > because we keep the buffer heads on active pages in memory...
> 
> A page can be the most active and the VM and never need bh on it
> after the first pagein. Keeping the bh on it means wasting tons
> of memory for no good reason.

Indeed. On the other hand, maybe we /will/ need the buffer
head again soon?

Linus, I remember you saying some time ago that you would
like to keep the buffer heads on a page around so we'd
have them at the point where we need to swap out again.

Is this still your position or should I make some code to
strip the buffer heads of clean, active pages ?

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
