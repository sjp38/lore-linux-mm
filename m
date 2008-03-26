Date: Wed, 26 Mar 2008 23:19:50 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 1/6] compcache: compressed RAM block device
Message-ID: <20080326221950.GA4064@ucw.cz>
References: <200803242032.40589.nitingupta910@gmail.com> <87a5b0800803240923m1ec9e343ld08c2828fe42e4e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87a5b0800803240923m1ec9e343ld08c2828fe42e4e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Will Newton <will.newton@gmail.com>
Cc: nitingupta910@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> >  --- /dev/null
> >  +++ b/drivers/block/compcache.c
> >  @@ -0,0 +1,440 @@
> >  +/*
> >  + * Compressed RAM based swap device
> >  + *
> >  + * (C) Nitin Gupta
> 
> Should add a copyright year.

...and GPL.

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
