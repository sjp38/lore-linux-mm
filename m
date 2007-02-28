Date: Wed, 28 Feb 2007 11:14:48 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Remove page flags for software suspend
Message-ID: <20070228101448.GB8536@elf.ucw.cz>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <200702161156.21496.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200702161156.21496.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> > I think we can just move the flags completely into the kernel/power 
> > directory? This centralizes all your handling of pageflags into snapshot.c 
> > so that you need no external definitions anymore.
> 
> Yes, I think we can do it this way, but can we generally assume that the
> offset for eg. test_bit() won't be taken modulo 32 (or 64)?
> 
> And ...

Ouch... I somehow assumed it was Nigel doing this patch, and noticed
too late. Sorry.

I still wish to be cc-ed on swsusp changes.
								Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
