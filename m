Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C92286B004F
	for <linux-mm@kvack.org>; Tue, 26 May 2009 15:03:40 -0400 (EDT)
Date: Tue, 26 May 2009 21:02:50 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090526190249.GA1326@ucw.cz>
References: <20090520183045.GB10547@oblivion.subreption.com> <1242852158.6582.231.camel@laptop> <4A15A69F.3040604@redhat.com> <20090521202628.39625a5d@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090521202628.39625a5d@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi!

> > I could also imagine the suspend-to-disk code skipping
> > PG_sensitive pages when storing data to disk, and
> > replacing it with some magic signature so programs
> > that use special PG_sensitive buffers can know that
> > their crypto key disappeared after a restore.
> 
> Its irrelevant in the simple S2D case. I just patch other bits of the
> suspend image to mail me the new key later. The right answer is crypted
> swap combined with a hard disk password and thus a crypted and locked
> suspend image. Playing the "I must not miss any page which might be

uswsusp does have internal encryption, and can use dm_crypt encrypted
swap... So yes, we can do encrypted swap & s2disk today.
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
