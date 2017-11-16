Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8136B0294
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 02:22:42 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 107so13998576wra.7
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 23:22:42 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 140sor186895wmu.8.2017.11.15.23.22.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Nov 2017 23:22:40 -0800 (PST)
Date: Thu, 16 Nov 2017 08:22:37 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] locking/Documentation: Revise
 Documentation/locking/crossrelease.txt
Message-ID: <20171116072237.jcztqvlnzerzyozh@gmail.com>
References: <1510406792-28676-1-git-send-email-byungchul.park@lge.com>
 <1510407214-31452-1-git-send-email-byungchul.park@lge.com>
 <20171111134524.GA16714@X58A-UD3R>
 <20171116000456.GB4394@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171116000456.GB4394@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com


* Byungchul Park <byungchul.park@lge.com> wrote:

> On Sat, Nov 11, 2017 at 10:45:24PM +0900, Byungchul Park wrote:
> > This is the big one including all of version 3.
> > 
> > You can take only this.
> 
> Hello Ingo,
> 
> Could you consider this?

Yeah, I'll have a look in a few days, but right now we are in the middle of the 
merge window.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
