Date: Wed, 28 Feb 2007 21:22:36 +0000
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Remove page flags for software suspend
Message-ID: <20070228212235.GD4760@ucw.cz>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <200702161156.21496.rjw@sisk.pl> <20070228101403.GA8536@elf.ucw.cz> <Pine.LNX.4.64.0702280724540.16552@schroedinger.engr.sgi.com> <20070228210837.GA4760@ucw.cz> <Pine.LNX.4.64.0702281315560.28432@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0702281315560.28432@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 2007-02-28 13:16:51, Christoph Lameter wrote:
> On Wed, 28 Feb 2007, Pavel Machek wrote:
> 
> > Hmm, can't we just add another word to struct page?

?

> > Plus we really need PageNosave from boot on...
> 
> Well it would be great to get the story straight. First I was told that 
> the bitmaps can be allocated later. Now we dont. The current patch should 
> do what you want.

PageNosave is set by boot code in some cases, as Rafael told you.

It may be possible to redo boot processing at suspend time, but it
would be ugly can of worms, I'm not sure if BIOS data are still
available, and neccessary functions are probably __init.

							Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
