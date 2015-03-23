Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 611546B006C
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 17:26:09 -0400 (EDT)
Received: by wgdm6 with SMTP id m6so156409742wgd.2
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 14:26:09 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id dx5si13636936wib.57.2015.03.23.14.26.07
        for <linux-mm@kvack.org>;
        Mon, 23 Mar 2015 14:26:08 -0700 (PDT)
Date: Mon, 23 Mar 2015 22:26:05 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: rowhammer and pagemap (was Re: [RFC, PATCH] pagemap: do not leak
 physical addresses to non-privileged userspace)
Message-ID: <20150323212605.GG14779@amd>
References: <1425935472-17949-1-git-send-email-kirill@shutemov.name>
 <20150316211122.GD11441@amd>
 <CAL82V5O6awBrpj8uf2_cEREzZWPfjLfqPtRbHEd5_zTkRLU8Sg@mail.gmail.com>
 <CALCETrU8SeOTSexLOi36sX7Smwfv0baraK=A3hq8twoyBN7NBg@mail.gmail.com>
 <20150317111653.GA23711@amd>
 <20150317175859.1d9555fc@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150317175859.1d9555fc@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: Andy Lutomirski <luto@amacapital.net>, Mark Seaborn <mseaborn@chromium.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>


> > > The Intel people I asked last week weren't confident.  For one thing,
> > > I fully expect that rowhammer can be exploited using only reads and
> > > writes with some clever tricks involving cache associativity.  I don't
> > > think there are any fully-associative caches, although the cache
> > > replacement algorithm could make the attacks interesting.
> > 
> > We should definitely get Intel/AMD to disable CLFLUSH, then.
> 
> I doubt that would work, because you'd have to fix up all the faults from
> userspace in things like graphics and video. Whether it is possible to
> make the microcode do other accesses and delays I have no idea - but
> that might also be quite horrible.
> 
> A serious system should be using ECC memory anyway. and on things like
> shared boxes it is probably not a root compromise that is the worst case
> scenario but subtle undetected corruption of someone elses data
> sets.

Both are bad. It is fairly hard to do rowhammer by accident, so if you
are hitting it, someone is probably doing it on purpose. And cloud
providers seem to be case of "serious systems" without ECC...

(I seem to remember accidental rowhammer with spinlocks, will have to
check that again).

> That's what ECC already exists to protect against whether its from flawed
> memory and rowhammer or just a vindictive passing cosmic ray.

Well, there's more than thre orders of magnitude difference between
cosmic rays and rowhammer. IIRC cosmic rays are expected to cause 2
bit flips a year... rowhammer can do bitflip in 10 minutes, and that
is old version, not one of the optimized ones. 

Best regards,
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
