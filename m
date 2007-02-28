Date: Wed, 28 Feb 2007 21:08:38 +0000
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Remove page flags for software suspend
Message-ID: <20070228210837.GA4760@ucw.cz>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <200702161156.21496.rjw@sisk.pl> <20070228101403.GA8536@elf.ucw.cz> <Pine.LNX.4.64.0702280724540.16552@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0702280724540.16552@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> > I... actually do not like that patch. It adds code... at little or no
> > benefit.
> 
> We are looking into saving page flags since we are running out. The two 
> page flags used by software suspend are rarely needed and should be taken 
> out of the flags. If you can do it a different way then please do.

Hmm, can't we just add another word to struct page?

Plus we really need PageNosave from boot on...

							Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
