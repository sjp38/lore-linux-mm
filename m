Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D78B76B01F2
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 08:55:15 -0400 (EDT)
Date: Tue, 27 Apr 2010 14:55:03 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
Message-ID: <20100427125502.GA3681@ucw.cz>
References: <53c81c97-b30f-4081-91a1-7cef1879c6fa@default>
 <4BD07594.9080905@redhat.com>
 <b1036777-129b-4531-a730-1e9e5a87cea9@default>
 <4BD16D09.2030803@redhat.com>
 <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>
 <4BD1A74A.2050003@redhat.com>
 <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>
 <4BD1B427.9010905@redhat.com>
 <b559c57a-0acb-4338-af21-dbfc3b3c0de5@default4BD336CF.1000103@redhat.com>
 <d1bb78ca-5ef6-4a8d-af79-a265f2d4339c@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d1bb78ca-5ef6-4a8d-af79-a265f2d4339c@default>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hi!

> > Can we extend it?  Adding new APIs is easy, but harder to maintain in
> > the long term.
> 
> Umm... I think the difference between a "new" API and extending
> an existing one here is a choice of semantics.  As designed, frontswap
> is an extremely simple, only-very-slightly-intrusive set of hooks that
> allows swap pages to, under some conditions, go to pseudo-RAM instead
...
> "Extending" the existing swap API, which has largely been untouched for
> many years, seems like a significantly more complex and error-prone
> undertaking that will affect nearly all Linux users with a likely long
> bug tail.  And, by the way, there is no existence proof that it
> will be useful.

> Seems like a no-brainer to me.

Stop right here. Instead of improving existing swap api, you just
create one because it is less work.

We do not want apis to cummulate; please just fix the existing one.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
