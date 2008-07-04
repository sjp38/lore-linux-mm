Date: Thu, 3 Jul 2008 20:18:56 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Message-ID: <20080704001855.GJ30506@mit.edu>
References: <1215093175.10393.567.camel@pmac.infradead.org> <20080703173040.GB30506@mit.edu> <1215111362.10393.651.camel@pmac.infradead.org> <20080703.162120.206258339.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080703.162120.206258339.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: dwmw2@infradead.org, jeff@garzik.org, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 03, 2008 at 04:21:20PM -0700, David Miller wrote:
> > And given the GPL's explicit provisions with regard to collective works
> > there are also entirely reasonable, non-"fundamentalist" grounds for
> > believing that it _may_ pose a licensing problem, and for wanting to err
> > on the side of caution in that respect too.
> 
> So now the real truth is revealed.  You have no technical basis for
> this stuff you are ramming down everyone's throats.
> 
> You want to choose a default based upon your legal agenda.

Yep, legal agenda.  As I suspected, licensing religious fundamentalism.  :-)

People who care can change the defaults.  People who are real
religious nuts won't even let the firmware live in the same source
tarball.  But I hope you agree we clearly don't have consensus to take
*that* step (rip out all firmware and make a whole bunch of drivers
non-functional and forcing users to go on a treasure-hunt to find some
new tarball they have to install on their existing system).  So given
that we're not ready to take that step, why not just leave the default
as "yes" for now?

The staged approach means that if you really want to do this ASAP,
then start assembling the firmware tarball *now*, and for a while
(read: at least 9-18 months) we can distribute firmware both in the
kernel source tarball as well as separately in the
licensing-religion-firmware tarball.  See if you can get distros
willing to ship it by default in most user's systems, and give people
plenty of time to understand that we are trying to decouple firmware
from the kernel sources.  If we need to institute better versioning
regimes between the drivers and firmware release levels, that will
also give people a chance to get that all right.  Then 6-9 months
later, we can turn the default to 'no', and then maybe another 6-9
months after that, we can talk about removing the firmware modules.
But it seems to me that you are skipping a few steps by arguing that
the default should be changed here-and-now.

We've been shipping firmware in the kernel for over a ***decade***; in
fact, probably over 15 years.  For people who are legal freaks/geeks,
look up the legal terms "Estoppel" and "Laches".  That provides a
fairly large amount of protection right there.  For people who aren't
legal geeks, we've been doing this for well over a decade; another
year or two really isn't a big deal.  It certainly doesn't justify
breaking users by default just to try to hurry up this process.

> If it was purely technical, you wouldn't be choosing defaults that
> break things for users by default.  Jeff and I warned you about this
> from day one, you did not listen, and now we have at least 10 reports
> just today of people with broken networking.

Not 15 minutes after David posted his note, we're now up to 11
reports; and this is only from an -mm patch series.  Can you imagine
the number of bug reports if this were allowed to ship in a mainline
kernel.org release?  One good thing is that we can definitely show
that there people that are downloading, compiling and trying to build
the -mm kernel.  :-)

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
