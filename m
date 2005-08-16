Date: Tue, 16 Aug 2005 15:59:00 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC][PATCH] Rename PageChecked as PageMiscFS
Message-ID: <20050816135900.GA3326@elf.ucw.cz>
References: <200508121329.46533.phillips@istop.com> <200508110812.59986.phillips@arcor.de> <20050808145430.15394c3c.akpm@osdl.org> <26569.1123752390@warthog.cambridge.redhat.com> <5278.1123850479@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5278.1123850479@warthog.cambridge.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Daniel Phillips <phillips@istop.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi!

> > You also achieved some sort of new low point in the abuse of StudlyCaps
> > there.  Please, let's not get started on mixed case acronyms.
> 
> My patch has been around for quite a while, and no-one else has complained,
> not even you before this point. Plus, you don't seem to be complaining about
> PageSwapCache... nor even PageLocked.

PageFsMisc really *is* ugly and hard to read. PageLocked etc. look
bad, too but ThIs iS rEaLlY WrOnG.

PageMisc would look less ugly, make note in a comment that it is for
filesystems only.

									Pavel
-- 
if you have sharp zaurus hardware you don't need... you know my address
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
