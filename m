Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 036CFC41517
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 23:48:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B227F2084C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 23:48:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GTEVk08h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B227F2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DE356B0003; Thu, 25 Jul 2019 19:48:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 590776B0005; Thu, 25 Jul 2019 19:48:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4579B6B0006; Thu, 25 Jul 2019 19:48:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1DCCD6B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 19:48:50 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id j4so28202883otc.5
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 16:48:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0/601dflBui9fUKU13mAsQ6rd2OiEZJpX1vt/upGwrU=;
        b=a75AunktyjeAufVX6STWiM1aJ3nXuU/zQ1EJkiRLqACNcJK7Whw62/ZZvgONR0PY4e
         8XsDgKPt2gU+MCkwZPsJSHuYT4N00DDRqB8FS+xrsPX2tmf1ywBoQfwZ1Lzndz8eTm05
         +WkTruGhWkDdiyOuCbGwpAG3mbb7sVZ9RZtzamd9YzFizvhCBBLch6fwsWy4Z0SPfaSp
         OsSWz+wZ0XPj+YdVpQzovtX5P3zaHNiFit8v49Jqg5TorXMhTVYov+R/ZPzlusgUyHZV
         6Ke4zV2FJh+C1+E19ZhwfoncXgYwv5i/psPucVdtbOAGoqTTEg9unxhQiFBpVC3wY3yX
         o7Zw==
X-Gm-Message-State: APjAAAXvdGW7dqNPFpp62WlkidxGzn2SsZ7AvhhODtT3yb/WcvIrKKxF
	01QUh7aS8jF9fVagWfL3eKz2/TUtxCqpnx1l4ijsoKg+NAUlvcDYSADkUzDFyze4PQBTOGDjE+Z
	0t3Gg0scs3ws9mfcLvz2xUoha/JN/87gweSxIFjGnj4IClyEAnOTfE7wa8cpK4pPyAA==
X-Received: by 2002:a9d:5a91:: with SMTP id w17mr37398845oth.32.1564098529681;
        Thu, 25 Jul 2019 16:48:49 -0700 (PDT)
X-Received: by 2002:a9d:5a91:: with SMTP id w17mr37398797oth.32.1564098528523;
        Thu, 25 Jul 2019 16:48:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564098528; cv=none;
        d=google.com; s=arc-20160816;
        b=jiAe4Ti/G6xxf4ugKet6/Ff4Hjh7LqbcVEZ7910q8lBVqe12SkxC0aLOi/GysycOiq
         xrZJ38JrDBbNrJmjAgZgA8uG9Nt7htOUHkWIvi0wn7EZJRL6j6x/He2hQG8UAQghIiuK
         76jJ24eSJt2DJsWLfB6d22H2hSiYhwhFj6yxofUvqJJp42hOAiMWOuNqqLm/ZRg0JdRP
         W9Ha1c9fjTP9aT9qqk44bA5+3AimPbeORyvVofY0kMkKsihCfPv/ndXjnDKbcaSJdvTl
         uJGyEOqBimhWGiTDV9bmjj+5ncDUvdSxzaiulPbzA0nOMY8KkYHHN85VtRmTiUPvqjuq
         Z8rA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0/601dflBui9fUKU13mAsQ6rd2OiEZJpX1vt/upGwrU=;
        b=ijTAQiEFaT4iqMO4eKe3actAp4xmQUy1q3la44XxirkFAldwb0RwnAB21lDczZ0aEp
         LyyCu70XygUAxngviFuUNRoZwm4o2Q+Yab2AMLZE7K1e9lSCrAQUJLi6CcekOW33XLIq
         6rs2RqzBskDsDQkyur8lCzoc9BHniccO5g1IEC1uaYM95st0d1eZPK3g0WU3N/gRcCOt
         O20n/LtAiCmCWhb86MUX05lttPiRYjhYA4H3BKy668gjgl2+vSki8xhRnsgfklYWqk4z
         8VJgq6dn2tIZAVppQWk/NlBl5W5fROecEevv1Gie1t7s0YvGhZqzKmOo/ZfvZcteBQHM
         J+Eg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GTEVk08h;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a4sor26516536otl.147.2019.07.25.16.48.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 16:48:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GTEVk08h;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0/601dflBui9fUKU13mAsQ6rd2OiEZJpX1vt/upGwrU=;
        b=GTEVk08hKujXGWe5eMnIgIADu2PDqqGQHd1fXyoOBVjcUi9jRRJQvLA7UY9mzOtUW7
         MvzofGlJrbylhZ+E0lPaGRZiSHVQCWIiFDaZobfAZZHIx3NPzA781HBRhvzgSuqUTEF8
         chlv2uucelGR7GZieGehPxRdXXh5P42GVVqbzjdkg+sW1KfpUbUystcuygosJPfM4ChO
         tMJF6yqP554r383UvBqO6oHO5yB4tdl3Qodr8zELOPhAdXvu1eVW5OGFZZNCaRAooBya
         wlT3wHBHEBGbl3FLD4Gbu0Gr2KQ8kPIZMC+p8qy1RLYB9A9sljlTrM9y0e4Xg13/aEl1
         3QHg==
X-Google-Smtp-Source: APXvYqwwrd1A4w1ujcS1G8VV0f9obBolPkKbeDxwmn74a0mZM1Q3fruAl5PiPEU3KMAmQeS4ihLVDIlAxJswctoCjVI=
X-Received: by 2002:a05:6830:2098:: with SMTP id y24mr25212379otq.173.1564098528292;
 Thu, 25 Jul 2019 16:48:48 -0700 (PDT)
MIME-Version: 1.0
References: <20190725184253.21160-1-lpf.vector@gmail.com> <1564080768.11067.22.camel@lca.pw>
In-Reply-To: <1564080768.11067.22.camel@lca.pw>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Fri, 26 Jul 2019 07:48:36 +0800
Message-ID: <CAD7_sbEXQt0oHuD01BXdW2_=G4h8U8ogHVt0N1Yez2ajFJkShw@mail.gmail.com>
Subject: Re: [PATCH 00/10] make "order" unsigned int
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, mhocko@suse.com, 
	vbabka@suse.cz, aryabinin@virtuozzo.com, osalvador@suse.de, 
	rostedt@goodmis.org, mingo@redhat.com, pavel.tatashin@microsoft.com, 
	rppt@linux.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 2:52 AM Qian Cai <cai@lca.pw> wrote:
>
> On Fri, 2019-07-26 at 02:42 +0800, Pengfei Li wrote:
> > Objective
> > ----
> > The motivation for this series of patches is use unsigned int for
> > "order" in compaction.c, just like in other memory subsystems.
>
> I suppose you will need more justification for this change. Right now, I don't

Thanks for your comments.

> see much real benefit apart from possibly introducing more regressions in those

As you can see, except for patch [05/10], other commits only modify the type
of "order". So the change is not big.

For the benefit, "order" may be negative, which is confusing and weird.
There is no good reason not to do this since it can be avoided.

> tricky areas of the code. Also, your testing seems quite lightweight.
>

Yes, you are right.
I use "stress" for stress testing, and made some small code coverage testing.

As you said, I need more ideas and comments about testing.
Any suggestions for testing?

Thanks again.

--
Pengfei

> >
> > In addition, did some cleanup about "order" in page_alloc
> > and vmscan.
> >
> >
> > Description
> > ----
> > Directly modifying the type of "order" to unsigned int is ok in most
> > places, because "order" is always non-negative.
> >
> > But there are two places that are special, one is next_search_order()
> > and the other is compact_node().
> >
> > For next_search_order(), order may be negative. It can be avoided by
> > some modifications.
> >
> > For compact_node(), order = -1 means performing manual compaction.
> > It can be avoided by specifying order = MAX_ORDER.
> >
> > Key changes in [PATCH 05/10] mm/compaction: make "order" and
> > "search_order" unsigned.
> >
> > More information can be obtained from commit messages.
> >
> >
> > Test
> > ----
> > I have done some stress testing locally and have not found any problems.
> >
> > In addition, local tests indicate no performance impact.
> >
> >
> > Pengfei Li (10):
> >   mm/page_alloc: use unsigned int for "order" in should_compact_retry()
> >   mm/page_alloc: use unsigned int for "order" in __rmqueue_fallback()
> >   mm/page_alloc: use unsigned int for "order" in should_compact_retry()
> >   mm/page_alloc: remove never used "order" in alloc_contig_range()
> >   mm/compaction: make "order" and "search_order" unsigned int in struct
> >     compact_control
> >   mm/compaction: make "order" unsigned int in compaction.c
> >   trace/events/compaction: make "order" unsigned int
> >   mm/compaction: use unsigned int for "compact_order_failed" in struct
> >     zone
> >   mm/compaction: use unsigned int for "kcompactd_max_order" in struct
> >     pglist_data
> >   mm/vmscan: use unsigned int for "kswapd_order" in struct pglist_data
> >
> >  include/linux/compaction.h        |  30 +++----
> >  include/linux/mmzone.h            |   8 +-
> >  include/trace/events/compaction.h |  40 +++++-----
> >  include/trace/events/kmem.h       |   6 +-
> >  include/trace/events/oom.h        |   6 +-
> >  include/trace/events/vmscan.h     |   4 +-
> >  mm/compaction.c                   | 127 +++++++++++++++---------------
> >  mm/internal.h                     |   6 +-
> >  mm/page_alloc.c                   |  16 ++--
> >  mm/vmscan.c                       |   6 +-
> >  10 files changed, 126 insertions(+), 123 deletions(-)
> >

