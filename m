Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 94CD06B0047
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 11:23:50 -0500 (EST)
Received: by pxi5 with SMTP id 5so1709719pxi.12
        for <linux-mm@kvack.org>; Sun, 17 Jan 2010 08:23:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1263745267.2162.42.camel@barrios-desktop>
References: <1263549544.3112.10.camel@maxim-laptop>
	 <201001162317.39940.rjw@sisk.pl> <201001170138.37283.rjw@sisk.pl>
	 <201001171455.55909.rjw@sisk.pl>
	 <1263745267.2162.42.camel@barrios-desktop>
Date: Mon, 18 Jan 2010 01:23:48 +0900
Message-ID: <28c262361001170823s445591fao1fca4bc539a27125@mail.gmail.com>
Subject: Re: [linux-pm] [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume
	(was: Re: Memory allocations in .suspend became very unreliable)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Maxim Levitsky <maximlevitsky@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> I think we can use lockdep annotation, too. but it's overkill.
> That's because suspend/resume is rare event so that I want to add

so that I don't want to add

Sorry for the typo.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
