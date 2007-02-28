Date: Wed, 28 Feb 2007 21:11:48 +0000
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Remove page flags for software suspend
Message-ID: <20070228211148.GB4760@ucw.cz>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <200702281833.03914.rjw@sisk.pl> <Pine.LNX.4.64.0702280932160.5371@schroedinger.engr.sgi.com> <200702281851.51666.rjw@sisk.pl> <Pine.LNX.4.64.0702280950460.15607@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0702280950460.15607@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> > Well, yes, I think so.  Still, there may be another way of doing it and I need
> > some time to have a look.
> > 
> > BTW, have you tested the patch?
> 
> Nope. Sorry, have no use for software suspend.

It is a matter of adding resume=/dev/hda9 to kernel cmdline and then echo disk
> /sys/power/state... I guess that is not too much to ask?

Anyway, if you want to submit patch to swsusp, please test it, and cc
me on that mail.
							Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
