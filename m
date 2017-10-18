Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 935856B0253
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 13:05:54 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p186so2392224wmd.11
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 10:05:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v9sor5474199wre.32.2017.10.18.10.05.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Oct 2017 10:05:53 -0700 (PDT)
Date: Wed, 18 Oct 2017 19:05:50 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/2] lockdep: Introduce CROSSRELEASE_STACK_TRACE and make
 it not unwind as default
Message-ID: <20171018170550.qycebtl4y2xrpiy5@gmail.com>
References: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
 <alpine.DEB.2.20.1710181519580.1925@nanos>
 <20171018133019.cwfhnt46pvhirt57@gmail.com>
 <alpine.DEB.2.20.1710181533260.1925@nanos>
 <20171018141502.GB12063@bombadil.infradead.org>
 <alpine.DEB.2.20.1710181634420.1925@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1710181634420.1925@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Matthew Wilcox <willy@infradead.org>, Byungchul Park <byungchul.park@lge.com>, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com


* Thomas Gleixner <tglx@linutronix.de> wrote:

> On Wed, 18 Oct 2017, Matthew Wilcox wrote:
> 
> > On Wed, Oct 18, 2017 at 03:36:05PM +0200, Thomas Gleixner wrote:
> > > Which reminds me that I wanted to convert them to static_key so they are
> > > zero overhead when disabled. Sigh, why are todo lists growth only?
> > 
> > This is why you need an Outreachy intern -- it gets at least one task
> > off your todo list, and in the best possible case, it gets a second
> > person working on your todo list for a long time.
> > 
> > ... eventually they start their own todo lists ...
> 
> Good idea. Oh, wait.....  Getting an Outreachy intern is on my todo list already. 

Please add "shrink my TODO list" to your TODO list ... wait a minute ...

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
