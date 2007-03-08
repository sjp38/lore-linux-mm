Date: Fri, 9 Mar 2007 00:36:18 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC][PATCH 0/3] swsusp: Do not use page flags (was: Re: Remove page flags for software suspend)
Message-ID: <20070308233618.GE2793@elf.ucw.cz>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <20070308231512.GB1977@elf.ucw.cz> <1173396094.3831.42.camel@johannes.berg> <200703090034.57978.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200703090034.57978.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Johannes Berg <johannes@sipsolutions.net>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, pm list <linux-pm@lists.osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Hi!

> > > That's a no-no. ATOMIC alocations can fail, and no, WARN_ON is not
> > > enough. It is not a bug, they just fail.
> > 
> > But like I said in my post, there's no way we can disable suspend to
> > disk when they do, right now anyway. Also, this can't be called any
> > later than a late initcall or such since it's __init, and thus there
> > shouldn't be memory pressure yet that would cause this to fail.
> 
> Exactly.  If an atomic allocation fails at this stage, there is a bug IMHO
> (although not necessarily in our code).

Ok, so just do a BUG().	 WARN_ON(), then do something subtly wrong
during suspend is evil.
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
