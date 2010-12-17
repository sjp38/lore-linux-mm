Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C543C6B0098
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 10:53:47 -0500 (EST)
In-reply-to: <AANLkTinhkZKWkthN1R39+6nDbN0xZq-g7jP5-LVLxZ3E@mail.gmail.com>
	(message from Minchan Kim on Fri, 17 Dec 2010 10:40:51 +0900)
Subject: Re: [PATCH] mm: add replace_page_cache_page() function
References: <E1PStc6-0006Cd-0Z@pomaz-ex.szeredi.hu>
	<AANLkTikXQmsgZ8Ea-GoQ4k2St6yCJj8Z3XthuBQ9u+EV@mail.gmail.com>
	<E1PTCV4-0007sR-SO@pomaz-ex.szeredi.hu>
	<20101216220457.GA3450@barrios-desktop>
	<alpine.LSU.2.00.1012161708260.3351@tigran.mtv.corp.google.com> <AANLkTinhkZKWkthN1R39+6nDbN0xZq-g7jP5-LVLxZ3E@mail.gmail.com>
Message-Id: <E1PTcch-0001bp-7s@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 17 Dec 2010 16:53:35 +0100
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: hughd@google.com, miklos@szeredi.hu, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Dec 2010, Minchan Kim wrote:
> >> >
> >> > I suspect it's historic that page_cache_release() doesn't drop the
> >> > page cache ref.
> >>
> >> Sorry I can't understand your words.
> >
> > Me neither: I believe Miklos meant __remove_from_page_cache() rather
> > than page_cache_release() in that instance.
> 
> Maybe. :)

Yeah, I did mean remove_from_page_cache :)

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
