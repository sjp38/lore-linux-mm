Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA05395
	for <linux-mm@kvack.org>; Tue, 18 Nov 1997 13:11:23 -0500
Date: Tue, 18 Nov 1997 12:55:42 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: memory management things to hack...
In-Reply-To: <3470B9BB.4B72194C@misic.soc.cornell.edu>
Message-ID: <Pine.LNX.3.91.971118124551.1725A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Koni <koni@misic.soc.cornell.edu>
Cc: linux-kernel@vger.rutgers.edu, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Nov 1997, Koni wrote:

> To the person who requested mem management things to hack:
> (I don't have your address I think because I joined the list too late)

That's me...

> I have an SMP machine (2 PPro cpus) with 512M (well, I'd like to say it
> has 512M). I can confirm for anyone who wants to know that 2.0.30 works
> fine with 256M of ram. However, it crashes almost immediately (during
> boot) when the machine has 512M of ram installed. It doesn't even work
> if I use "mem=256M" ( i don't know why). Now, I have managed to get the
> machine usable with 512M by using kernel 2.1.62.

Good, 2.1.62 continually crashed at my place:) It's only stable
again with 2.1.64 (and my patch).

> Questions: why does 2.1.62 work? (Machine has been runing 4 days now -
> but not without some odd quirks, not sure if its because its 2.1.X or if
> not all is well with 512M still, or both)

I don't know why it works. But _if_ it works there's no reason
not to use it.

> can whatever be incorporated into next 2.0.X kernel?

It will be in 2.2, but a lot of things just _can't_ be ported
to 2.0 due to some fundamental differences in memory management.

> some odd quirks observed:
>     -our model ("CORSIM" - http://misic.soc.cornell.edu) crashes at a
> weird spot now with "error closing file." This may be related to new C
> libraries however.
>     -users complain of FTPed file corruptions. (they might at fault)
>     -System crashed while FTPing a large file.
>     -mouse skips all around the screen at random times (and clicks on
> things at random) as if someone was writing into /dev/mouse.
>     -telnet from or to any machine which is not also linux is bizarre
> (suspect termcap library need upgrading or something, w/ respect to new
> C library maybe)

It all sounds like memory fragmentation is biting you... If you've
got some spare time you could try 2.1.64 with my patch (newest
version). I think the problems should be (at least) alleviated quite
a lot. If problems remain I could add some debugging messages to the
mm part and analize the log with you. We could add an even more
agressive anti-fragmentation strategy...

> Provided one of our staff figures out quirk#1, the rest seems minor. I
> am curious to know other's experiences with 2.1.62 as a "production"
> kernel rather than test kernel. Please email me
> (koni@misic.soc.cornell.edu) any other oddities that have been observed.

2.1.6[34] are running very stable here. 2.1.62 didn't (mainly due
to memory fragmentation??)

> Our "big" machine is usually under heavy use but occasionally over a
> weekend there is some idle time that I could use to test SMP kernels and
> memory management of 256M or 512M. Let me know if this is convienent for
> anyone.

Well, it sounds like the perfect machine to test my patch (it's
been thoroughly (sp) tested on smaller (<64M) machines, but never
on such a big machine.
I'd really apreciate it if you would like to stress-test my patch
on your machine and report any odd things (high CPU usage for
kswapd and vhand in particular) to me. Then I'll fix those things
next week...

You can find my patch on linux-mama and my homepage
<http://www.fys.ruu.nl/~riel/>.

success,

Rik.

----------
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
