Date: Mon, 17 Jul 2000 11:44:23 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] test5-1 vm fix
In-Reply-To: <Pine.Linu.4.10.10007170742550.445-100000@mikeg.weiden.de>
Message-ID: <Pine.LNX.4.21.0007171143100.30603-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@weiden.de>
Cc: Roger Larsson <roger.larsson@norran.net>, Linus Torvalds <torvalds@transmeta.com>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Jul 2000, Mike Galbraith wrote:
> On Sun, 16 Jul 2000, Rik van Riel wrote:
> > On Sun, 16 Jul 2000, Mike Galbraith wrote:
> > > Unfortunately, this didn't improve anything here.
> > 
> > As was to be expected ...
> 
> one can only hope and test.

Alternatively, one can learn from the patches and
mistakes of others and try to understand how stuff
works.

> > (and no, I'm not interested in trying to fix 2.4 VM right now
> > since I'll be going to OLS and last time it took only two weeks
> > for VM to be fucked up while I was away)
> 
> darn.
> 
> Do you already know what it's up to during one of these nasty
> stalls?

There's nothing wrong with the current VM that wasn't
fixed in one of my patches the last 8 weeks.

(except for the fundamental design flaws, which I will
fix in the *next* N+1 weeks)

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
