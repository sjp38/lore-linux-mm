Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA8C6B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 03:30:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u78so4510267wmd.13
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 00:30:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u50sor153229wrf.57.2017.10.20.00.30.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 00:30:53 -0700 (PDT)
Date: Fri, 20 Oct 2017 09:30:50 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 2/3] lockdep: Remove BROKEN flag of
 LOCKDEP_CROSSRELEASE
Message-ID: <20171020073050.nyaqynbbkeltr7iq@gmail.com>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
 <1508392531-11284-3-git-send-email-byungchul.park@lge.com>
 <1508425527.2429.11.camel@wdc.com>
 <alpine.DEB.2.20.1710191718260.1971@nanos>
 <1508428021.2429.22.camel@wdc.com>
 <alpine.DEB.2.20.1710192021480.2054@nanos>
 <alpine.DEB.2.20.1710192107000.2054@nanos>
 <1508444515.2429.55.camel@wdc.com>
 <alpine.DEB.2.20.1710192233130.2054@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1710192233130.2054@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Bart Van Assche <Bart.VanAssche@wdc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "byungchul.park@lge.com" <byungchul.park@lge.com>, "kernel-team@lge.com" <kernel-team@lge.com>


* Thomas Gleixner <tglx@linutronix.de> wrote:

> That would just make the door open for evading lockdep. This has been
> discussed when lockdep was introduced and with a lot of other 'annoying'
> debug features we've seen the same discussion happening.
> 
> When they get introduced the number of real issues and false positives is
> high, but once the dust settles it's just business as usual and the overall
> code quality improves and the number of hard to decode problems shrinks.

Yes, also note that it's typical that the proportion of false positives 
*increases* once a lock debugging feature enters a more mature period of its 
existence, because real deadlocks tend to be fixed at the development stage 
without us ever seeing them.

I.e. for every lockdep-debugged bug fixed upstream I'm pretty sure there are at 
least 10 times as many bugs that were fixed in earlier stages of development, 
without ever hitting the upstream kernel. At least that's the rough proportion
for locking bugs I introduce ;-)

So even false positives are not a problem as long as their annotation improves the 
code or documents it better.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
