Date: Mon, 9 Oct 2000 15:14:02 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010091159430.20087-100000@Megathlon.ESI>
Message-ID: <Pine.LNX.4.21.0010091510060.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marco Colombo <marco@esi.it>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Marco Colombo wrote:
> On Fri, 6 Oct 2000, Rik van Riel wrote:
> 
> [...]
> > They are niced because the user thinks them a bit less
> > important. 
> 
> Please don't, this assumption is quite wrong. I use nice just to
> be 'nice' to other users. I can run my *important* CPU hog
> simulation nice +10 in order to let other people get more CPU
> when the need it.

In that case the time the process has been running and the
CPU time used will save the process if it's been running for
a long time.

Please read the /entire/ algorithm before making rash
conclusions like this.

If nice is used for important, long-running tasks, the fact
that they are long-running will save them (and be honest,
would you really care if a simulation would be killed after
5 minutes?  it's only inconvenient if it gets killed after
a few hours...)

> But if you put the logic "niced == not important" somewhere into
> the kernel, nobody will use nice anymore. I'd rather give a
> bonus to niced processes.

This doesn't make ANY sense at all. The objective is to destroy
the least amount of work, which means giving a bonus to processes
which have used a lot of CPU time already ... regardless of nice
value.

> all. But my point here is that you do, and you take it as an hint for
> process importance as percieved by the user that run it, and I believe
> it's just wrong guessing).

If you have a better algorithm, feel free to send patches.

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
