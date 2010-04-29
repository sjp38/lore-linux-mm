Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1C3976B0216
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 09:04:34 -0400 (EDT)
Date: Thu, 29 Apr 2010 15:04:12 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
Message-ID: <20100429130411.GB1661@ucw.cz>
References: <b1036777-129b-4531-a730-1e9e5a87cea9@default>
 <4BD16D09.2030803@redhat.com>
 <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>
 <4BD1A74A.2050003@redhat.com>
 <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>
 <4BD1B427.9010905@redhat.com>
 <b559c57a-0acb-4338-af21-dbfc3b3c0de5@default4BD336CF.1000103@redhat.com>
 <d1bb78ca-5ef6-4a8d-af79-a265f2d4339c@default>
 <20100427125502.GA3681@ucw.cz>
 <4BD6F81B.1010606@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BD6F81B.1010606@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue 2010-04-27 20:13:39, Nitin Gupta wrote:
> On 04/27/2010 06:25 PM, Pavel Machek wrote:
> > 
> >>> Can we extend it?  Adding new APIs is easy, but harder to maintain in
> >>> the long term.
> >>
> >> Umm... I think the difference between a "new" API and extending
> >> an existing one here is a choice of semantics.  As designed, frontswap
> >> is an extremely simple, only-very-slightly-intrusive set of hooks that
> >> allows swap pages to, under some conditions, go to pseudo-RAM instead
> > ...
> >> "Extending" the existing swap API, which has largely been untouched for
> >> many years, seems like a significantly more complex and error-prone
> >> undertaking that will affect nearly all Linux users with a likely long
> >> bug tail.  And, by the way, there is no existence proof that it
> >> will be useful.
> > 
> >> Seems like a no-brainer to me.
> > 
> > Stop right here. Instead of improving existing swap api, you just
> > create one because it is less work.
> > 
> > We do not want apis to cummulate; please just fix the existing one.
> 
> 
> I'm a bit confused: What do you mean by 'existing swap API'?
> Frontswap simply hooks in swap_readpage() and swap_writepage() to
> call frontswap_{get,put}_page() respectively. Now to avoid a hardcoded
> implementation of these function, it introduces struct frontswap_ops
> so that custom implementations fronswap get/put/etc. functions can be
> provided. This allows easy implementation of swap-to-hypervisor,
> in-memory-compressed-swapping etc. with common set of hooks.

Yes, and that set of hooks is new API, right?

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
