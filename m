Date: Mon, 20 Apr 1998 22:55:31 +0100
Message-Id: <199804202155.WAA03972@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: I've got some patches to integrate, too...
In-Reply-To: <Pine.LNX.3.95.980415105437.839D-100000@as200.spellcast.com>
References: <m11zuz4vm5.fsf@flinx.npwt.net>
	<Pine.LNX.3.95.980415105437.839D-100000@as200.spellcast.com>
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 15 Apr 1998 11:11:07 -0400 (EDT), "Benjamin C.R. LaHaise"
<blah@kvack.org> said:

> Which reminds me: Stephen, what's the state of your irq and smp patches
> for page cache addition/removal.  I'm getting a bit more free time now, so
> perhaps I can play with them a bit (maybe we should have a common cvs
> tree...).

Sorry, I've been offline, away in Colorado, for over a week, or I'd
have answered this earlier...

The deferred pageout stuff (lazy page stealing) seems to work pretty
well.  It is rock solid when doing large compiles on a 6mb box, which
stresses swapping pretty heavily.  However, there is still a bug --- I
can reproduce a copy-on-write violation occasionally when running one
of my VM stress tests (I get a demand-zero page when I expect a
non-zero value, so there's a pte getting lost in there somewhere).
That's the only failure mode I can reproduce right now.

Right now I've got Linux Expo and Usenix deadlines approaching fast,
so there's a limit to how much time I can spend debugging code which
is not going to be integrated until 2.3.  I can't promise to get the
lazy page code debugged in the next couple of weeks.  With the feature
freeze in place, I guess there's a big question mark over whether this
code can get included in 2.2.  If it doesn't, then what we really need
to concentrate on is the memory fragmentation issues in 2.1, not the
new 2.2 features.

I spent a lot of time last week thinking about this, and there are a
number of things we can do in 2.1 which will help enormously.  I'll
write them up in a day or two (right now I'm still catching up my mail
backlog).  We can definitely improve things without making major
wholesale changes to the way VM works at the minute, even if it's not
going to give us quite the performance or power that the really new
code promises.

I guess that Linus really has to make the call whether or not we risk
destabilising the existing VM by adding the new code now, or whether
that is a 2.3 issue.  If it is a 2.3 thing, then 2.2 has more urgent
problems which need addressing as a higher priority than adding new
functionality.  We can still track the new VM code, but as a separate
branch which won't be integrated until 2.3 development starts (much
like the new net code which was integrated at the start of 1.3
development).

--Stephen
