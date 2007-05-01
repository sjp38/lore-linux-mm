Date: Tue, 1 May 2007 06:16:35 -0400 (EDT)
From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: pcmcia ioctl removal
In-Reply-To: <20070501094400.GX943@1wt.eu>
Message-ID: <Pine.LNX.4.64.0705010600140.9375@localhost.localdomain>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <20070501084623.GB14364@infradead.org> <Pine.LNX.4.64.0705010514300.9162@localhost.localdomain>
 <20070501094400.GX943@1wt.eu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-pcmcia@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 May 2007, Willy Tarreau wrote:

> On Tue, May 01, 2007 at 05:16:13AM -0400, Robert P. J. Day wrote:
... snip ...
> > in other words, the PCMCIA ioctl feature *has* been listed as
> > obsolete for quite some time, and is already a *year and a half*
> > overdue for removal.
> >
> > in short, it's annoying to take the position that stuff can't be
> > deleted without warning, then turn around and be reluctant to remove
> > stuff for which *more than ample warning* has already been given.
> > doing that just makes a joke of the features removal file, and makes
> > you wonder what its purpose is in the first place.
> >
> > a little consistency would be nice here, don't you think?
>
> No, it just shows how useless this file is.

agreed.  it's mildly entertaining to have watched this raging
discussion over the last few days regarding bugs and emails and
bugzilla and adrian's regressions, while the one feature that's meant
to track aging and removable kernel features is essentially valueless,
and no one seems to care.

> What is needed is a big warning during usage, not a file that nobody
> reads.

agreed there as well.  but short of that, it would still be nice if
people took a minute, perused the feature removal file, and at least
brought it up-to-date.  if it's going to have any value, then:

1) all proposed removal dates should be reviewed to make sure they're
still meaningful,

2) stuff that's overdue for removal should be either removed, or have
its expiry date brought forward, and

3) stuff in the kernel tree that is understood to be obsolete or
nearly so should have an entry added to that file, so that the clock
can at least *start* ticking for that stuff, and you can at least say
you *tried* to warn current users.

as a start, i posted last month the results of running the simple
command:

  $ grep -iw obsolete $(find . -name Kconfig\*)

and some of what was printed is clearly misleading.  (don't worry,
tilman -- we're not going to reopen that whole isdn4linux thing. :-)

i mean, what of the following is actually obsolete:

  * traffic policing
  * IP6 Userspace queueing via NETLINK
  * IP Userspace queueing via NETLINK
  * ebt: ulog support
  * Traffic Shaper

and so on (and there's that legacy PM thing as well).

> I'm sorry for your patch which may get delayed a lot.

obviously, leaving stuff like that in the kernel doesn't actually
*hurt* anything but, yeah, it's a tad annoying to invest a few minutes
to do some janitor work based on what should be killable, submit the
patch, then have people freak out about how that is still an essential
feature.

bottom line:  if you want janitor folks to help out with cleanup, make
sure they know what can legitimately be cleaned, and stop wasting
peoples' time.

rday

p.s.  now if there were only a way to, say, tag various kernel
features as "obsolete" or "deprecated" ...  :-)

-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
