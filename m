Date: Mon, 25 Sep 2000 13:09:47 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: the new VM
In-Reply-To: <20000925163909.O22882@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251308250.14614-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:
> On Mon, Sep 25, 2000 at 04:27:24PM +0200, Ingo Molnar wrote:
> > i think an application should not fail due to other applications
> > allocating too much RAM. OOM behavior should be a central thing and based
> 
> At least Linus's point is that doing perfect accounting (at
> least on the userspace allocation side) may cause you to waste
> resources, failing even if you could still run and I tend to
> agree with him. We're lazy on that side and that's global win in
> most cases.

OK, so do you guys want my OOM-killer selection code
in 2.4? ;)

(that will fix the OOM case in the rare situations
where it occurs and do the expected thing most of the
time)

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
