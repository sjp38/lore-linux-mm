Date: Fri, 2 Mar 2007 11:17:41 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Remove page flags for software suspend
Message-ID: <20070302101740.GC2293@elf.ucw.cz>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <200702281813.04643.rjw@sisk.pl> <45E6EEC5.4060902@yahoo.com.au> <200703012146.38307.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200703012146.38307.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> > Anyway, I guess if you want something done you have to do it yourself.
> > 
> > This patch still needs work (and I don't know if it even works, because
> > I can't make swsusp resume even on a vanilla kernel).
> 
> That's interesting, BTW, because recently I've been having problems with
> finding a machine on which it doesn't work. ;-)  If you could tell me (in
> private) what the problems are, I'd try to help.

Feel free to cc me.

(Actually, rafael, something is very wrong in 2.6.21-rc1+. I got
broken swsusp, s2ram, bluetooth and MMC.)
									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
