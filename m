Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by postfix.conectiva.com.br (Postfix) with SMTP id ED22716BCC
	for <linux-mm@kvack.org>; Fri,  6 Apr 2001 18:04:40 -0300 (EST)
Date: Fri, 6 Apr 2001 18:04:58 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <20010406222256.C935@athlon.random>
Message-ID: <Pine.LNX.4.33.0104061804400.7624-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Hugh Dickins <hugh@veritas.com>, Ben LaHaise <bcrl@redhat.com>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Apr 2001, Andrea Arcangeli wrote:
> On Fri, Apr 06, 2001 at 12:52:26PM -0700, Linus Torvalds wrote:
> > vm_enough_memory() is a heuristic, nothing more. We want it to reflect
> > _some_ view of reality, but the Linux VM is _fundamentally_ based on the
> > notion of over-commit, and that won't change. vm_enough_memory() is only
> > meant to give a first-order appearance of not overcommitting wildly. It
> > has never been anything more than that.
>
> 200% agreed.

I don't think we should approximate THAT roughly ;))

Rik
--
Linux MM bugzilla: http://linux-mm.org/bugzilla.shtml

Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
