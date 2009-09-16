Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 187FF6B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 04:45:13 -0400 (EDT)
Date: Wed, 16 Sep 2009 10:45:06 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: stack limits [was Re: 2.6.32 -mm merge plans]
Message-ID: <20090916084506.GA6862@elf.ucw.cz>
References: <20090915161535.db0a6904.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090915161535.db0a6904.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> - If you were bcc'ed on this email then you and I have unfinished
>   business.  Please see if you can work out what it is from the below and
>   let me know ;)

Was it this?

> #fdpic-ignore-the-loaders-pt_gnu_stack-when-calculating-the-stack-size.patch: pavel unhappy
> fdpic-ignore-the-loaders-pt_gnu_stack-when-calculating-the-stack-size.patch
> 
>   Elf.  Merge.  See if we can make Pavel happy.

It is not a big deal either way -- it is mostly theoretical -- but the
old code seems to be safer in those corner cases. I don't understand
why they are pushing it really.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
