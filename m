Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EFE1F6B0202
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 01:20:05 -0400 (EDT)
Date: Wed, 28 Apr 2010 07:55:39 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
Message-ID: <20100428055538.GA1730@ucw.cz>
References: <4BD16D09.2030803@redhat.com>
 <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>
 <4BD1A74A.2050003@redhat.com>
 <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>
 <4BD1B427.9010905@redhat.com>
 <4BD1B626.7020702@redhat.com>
 <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default>
 <4BD3377E.6010303@redhat.com>
 <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com>
 <ce808441-fae6-4a33-8335-f7702740097a@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ce808441-fae6-4a33-8335-f7702740097a@default>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hi!

> > Seems frontswap is like a reverse balloon, where the balloon is in
> > hypervisor space instead of the guest space.
> 
> That's a reasonable analogy.  Frontswap serves nicely as an
> emergency safety valve when a guest has given up (too) much of
> its memory via ballooning but unexpectedly has an urgent need
> that can't be serviced quickly enough by the balloon driver.

wtf? So lets fix the ballooning driver instead?

There's no reason it could not be as fast as frontswap, right?
Actually I'd expect it to be faster -- it can deal with big chunks.

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
