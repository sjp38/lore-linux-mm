Date: Mon, 25 Sep 2000 11:37:18 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: the new VM
In-Reply-To: <20000925150858.A22882@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251135390.14614-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:
> On Mon, Sep 25, 2000 at 03:02:58PM +0200, Ingo Molnar wrote:
> > On Mon, 25 Sep 2000, Andrea Arcangeli wrote:
> > 
> > > Sorry I totally disagree. If GFP_KERNEL are garanteeded to succeed
> > > that is a showstopper bug. [...]
> > 
> > why?
> 
> Because as you said the machine can lockup when you run out of memory.

The fix for this is to kill a user process when you're OOM
(you need to do this anyway).

The last few allocations of the "condemned" process can come
frome the reserved pages and the process we killed will exit just
fine.

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
