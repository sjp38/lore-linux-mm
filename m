Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5609C900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 17:30:20 -0400 (EDT)
Received: by iesa3 with SMTP id a3so143423859ies.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 14:30:20 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0232.hostedemail.com. [216.40.44.232])
        by mx.google.com with ESMTP id b17si15159137icn.94.2015.06.02.14.30.19
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 14:30:19 -0700 (PDT)
Message-ID: <1433280616.4861.102.camel@perches.com>
Subject: Re: [PATCH] MAINTAINERS: add zpool
From: Joe Perches <joe@perches.com>
Date: Tue, 02 Jun 2015 14:30:16 -0700
In-Reply-To: <CALZtONBVobxH--GGGdJaETScMorHKCY5ferHct74B79QDNDb4w@mail.gmail.com>
References: <1433264166-31452-1-git-send-email-ddstreet@ieee.org>
	 <1433279395.4861.100.camel@perches.com>
	 <CALZtONBVobxH--GGGdJaETScMorHKCY5ferHct74B79QDNDb4w@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Tue, 2015-06-02 at 17:19 -0400, Dan Streetman wrote:
> On Tue, Jun 2, 2015 at 5:09 PM, Joe Perches <joe@perches.com> wrote:
> > On Tue, 2015-06-02 at 12:56 -0400, Dan Streetman wrote:
> >> Add entry for zpool to MAINTAINERS file.
> > []
> >> diff --git a/MAINTAINERS b/MAINTAINERS
> > []
> >> @@ -11056,6 +11056,13 @@ L:   zd1211-devs@lists.sourceforge.net (subscribers-only)
> >>  S:   Maintained
> >>  F:   drivers/net/wireless/zd1211rw/
> >>
> >> +ZPOOL COMPRESSED PAGE STORAGE API
> >> +M:   Dan Streetman <ddstreet@ieee.org>
> >> +L:   linux-mm@kvack.org
> >> +S:   Maintained
> >> +F:   mm/zpool.c
> >> +F:   include/linux/zpool.h
> >
> > If zpool.h is only included from files in mm/,
> > maybe zpool.h should be moved to mm/ ?
> 
> It *could* be included by others, e.g. drivers/block/zram.
> 
> It currently is only used by zswap though, so yeah it could be moved
> to mm/.  Should I move it there, until (if ever) anyone outside of mm/
> wants to use it?

Up to you.

I think include/linux is a bit overstuffed and
whatever can be include local should be.

cheers, Joe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
