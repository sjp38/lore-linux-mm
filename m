Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9799AC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 05:44:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 061D4214DA
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 05:44:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sQjfjK3y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 061D4214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C76B8E0005; Wed, 31 Jul 2019 01:44:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 677E48E0001; Wed, 31 Jul 2019 01:44:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 566AD8E0005; Wed, 31 Jul 2019 01:44:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 217FB8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:44:55 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n1so36773459plk.11
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 22:44:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dhefx6+bI5/lxdg6oXf3wodWpmayqnB7DDdokXpcjMg=;
        b=j44c1bSQD1c3dnqyTJxiXNwJ5HwwZzzRnOfG7u3JErT54kCoP0CLiF8N6tBDD1CQz2
         6VuGXHbff1gxLXq8p4thxjc3ZyzpV4KOCIWl90KYfeNWRs/WIVo4Lan6SQGkvmaBpF+N
         F6V0d90ap13GVFh6578YHUXROxBNkfErzZHei2beoGOEPoU0w9MDxPirJYgrJ0naLeRN
         V0bUJXYh3y1gl0kcF+8m9GDg19UTuyahmuqyB19BEPj5bfDzvg3/mW9UTQTXURRRb9kz
         KweW7ckrLZBppMbPNDYwRP9m/MtkUi0WQrg623i8kReFZu76uJhjP6Ta6A+fcJ0iJRCV
         yiUg==
X-Gm-Message-State: APjAAAXpyO9eGKM8a6mH/9r91H7S+mdm/6nDMwgRc5wFZTF2JsWmJZay
	y8XLM8B5hh0y6QbSzM2hU+vTV507IYbKtoQM4Bv0fXLksU8jRWnMp1c9ncazMHxmHi8vLY0YP6D
	da2kEZ8TCbxC54DKgx+vLA2rkT1ASdDansnC2esBV+x9MAEBIp4+V9vFybTtXk44=
X-Received: by 2002:a17:902:100a:: with SMTP id b10mr77487722pla.338.1564551894575;
        Tue, 30 Jul 2019 22:44:54 -0700 (PDT)
X-Received: by 2002:a17:902:100a:: with SMTP id b10mr77487674pla.338.1564551893688;
        Tue, 30 Jul 2019 22:44:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564551893; cv=none;
        d=google.com; s=arc-20160816;
        b=Fs8pFiUMvlffVCWStyQV6M+BkiIyt6xZtQqTzQRJx+nJDNjjZd0nIuN5mBiSMeAifn
         lu+zSiaFyY9YCZS+lg8SE0/cDWEcGGDsLBpm8DNgJgzOvPyMYjkTgKSwZwaW4HB9Xz3Q
         s9QxO2xxgJJ1S1AEpr32T1WZiNJJdtswoy+e/3P1y8+v/sXRLQTF79012hpUEN9LD2KJ
         8PusySP6ZWrvKJtWThUKgPf+fuebOYSt7/fhrMtBIdGURomiqbe3y6POj6IN+sbN88xw
         bCy1LOQ/TAUzj/NRNg/mL8bK1ZwjUweQ8KqXh8LvmGOMqd/XRhxNp7ie3z0WZMKPE/4m
         FAlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=dhefx6+bI5/lxdg6oXf3wodWpmayqnB7DDdokXpcjMg=;
        b=Ku8o1POO6lNLGQ0xA8VvQbqEAo87VHprHtPO+pjTGdG5Ralg/UaYtDXus6rEDxVsff
         Sr0ZNI+7hrnHb5WyeBhdFjS4DZBxvVM/HBJ1ayjj6yjh5UO8IQBxwL6yHiVeZUfQT210
         eXm5rrKGc8kBKtDQjbGujuwhvz1US9AR6MbAOflZ02o24TMNAp/6+ZiXx2EIuihYekjc
         VJEkCA+kC2f3eLKfPSJEGpLfW9Yeb4d0PwoN7GuBKyqp2qvgP/QkfTM9eYF2x4RYcnhb
         /SlH9B3CjxMmqtEQlnK6nLRlQPzObC2yXsIAOHo0IcAVTzTSll7WrLFNNC1/JIZ/NVmq
         RpRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sQjfjK3y;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f2sor80912101plj.43.2019.07.30.22.44.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 22:44:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sQjfjK3y;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=dhefx6+bI5/lxdg6oXf3wodWpmayqnB7DDdokXpcjMg=;
        b=sQjfjK3y/z/3d1JS6WvWhqo3J5FttXfKN2QWJlL8hmfsh08bqrfKSPzjH+q2i2VfxF
         xCQ2z5zwl6OtquqRKi67ATkp1OfGjV+nBURLRH7z6cMVP9/Ky7KbQU8+zW7ugMs+KqBo
         QEj06w4vrVT8k1fVsIUC5EfRbHUEJ2wDz6aYPMDeLSVQ94ZV7+UV7Z4dJHGsisMijpxT
         fcWFYOMTGkQtcJFUc/aLLuFg6Ho13xn9gZpyIwvWNOgxyibFI8p/BvqXKZPrM2pCIP+N
         33IoFcZ99cw8qXIB+c0G9p+sH6OvabS41kyP/1hHSzxYUh5fTH1UR/x9J0Buw02Bp9SL
         0zaQ==
X-Google-Smtp-Source: APXvYqw+GsX0jKceDzctiXZbIk5pPQYlHAy301YmRVfmXsab/Hyl6L4qaNTVaKCKGnaLMO3DWpwiDQ==
X-Received: by 2002:a17:902:bd94:: with SMTP id q20mr108502842pls.307.1564551893301;
        Tue, 30 Jul 2019 22:44:53 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id w4sm86568867pfn.144.2019.07.30.22.44.50
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 30 Jul 2019 22:44:52 -0700 (PDT)
Date: Wed, 31 Jul 2019 14:44:47 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH] mm: release the spinlock on zap_pte_range
Message-ID: <20190731054447.GB155569@google.com>
References: <20190729071037.241581-1-minchan@kernel.org>
 <20190729074523.GC9330@dhcp22.suse.cz>
 <20190729082052.GA258885@google.com>
 <20190729083515.GD9330@dhcp22.suse.cz>
 <20190730121110.GA184615@google.com>
 <20190730123237.GR9330@dhcp22.suse.cz>
 <20190730123935.GB184615@google.com>
 <20190730125751.GS9330@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730125751.GS9330@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 02:57:51PM +0200, Michal Hocko wrote:
> [Cc Nick - the email thread starts http://lkml.kernel.org/r/20190729071037.241581-1-minchan@kernel.org
>  A very brief summary is that mark_page_accessed seems to be quite
>  expensive and the question is whether we still need it and why
>  SetPageReferenced cannot be used instead. More below.]
> 
> On Tue 30-07-19 21:39:35, Minchan Kim wrote:
> > On Tue, Jul 30, 2019 at 02:32:37PM +0200, Michal Hocko wrote:
> > > On Tue 30-07-19 21:11:10, Minchan Kim wrote:
> > > > On Mon, Jul 29, 2019 at 10:35:15AM +0200, Michal Hocko wrote:
> > > > > On Mon 29-07-19 17:20:52, Minchan Kim wrote:
> > > > > > On Mon, Jul 29, 2019 at 09:45:23AM +0200, Michal Hocko wrote:
> > > > > > > On Mon 29-07-19 16:10:37, Minchan Kim wrote:
> > > > > > > > In our testing(carmera recording), Miguel and Wei found unmap_page_range
> > > > > > > > takes above 6ms with preemption disabled easily. When I see that, the
> > > > > > > > reason is it holds page table spinlock during entire 512 page operation
> > > > > > > > in a PMD. 6.2ms is never trivial for user experince if RT task couldn't
> > > > > > > > run in the time because it could make frame drop or glitch audio problem.
> > > > > > > 
> > > > > > > Where is the time spent during the tear down? 512 pages doesn't sound
> > > > > > > like a lot to tear down. Is it the TLB flushing?
> > > > > > 
> > > > > > Miguel confirmed there is no such big latency without mark_page_accessed
> > > > > > in zap_pte_range so I guess it's the contention of LRU lock as well as
> > > > > > heavy activate_page overhead which is not trivial, either.
> > > > > 
> > > > > Please give us more details ideally with some numbers.
> > > > 
> > > > I had a time to benchmark it via adding some trace_printk hooks between
> > > > pte_offset_map_lock and pte_unmap_unlock in zap_pte_range. The testing
> > > > device is 2018 premium mobile device.
> > > > 
> > > > I can get 2ms delay rather easily to release 2M(ie, 512 pages) when the
> > > > task runs on little core even though it doesn't have any IPI and LRU
> > > > lock contention. It's already too heavy.
> > > > 
> > > > If I remove activate_page, 35-40% overhead of zap_pte_range is gone
> > > > so most of overhead(about 0.7ms) comes from activate_page via
> > > > mark_page_accessed. Thus, if there are LRU contention, that 0.7ms could
> > > > accumulate up to several ms.
> > > 
> > > Thanks for this information. This is something that should be a part of
> > > the changelog. I am sorry to still poke into this because I still do not
> > 
> > I will include it.
> > 
> > > have a full understanding of what is going on and while I do not object
> > > to drop the spinlock I still suspect this is papering over a deeper
> > > problem.
> > 
> > I couldn't come up with better solution. Feel free to suggest it.
> > 
> > > 
> > > If mark_page_accessed is really expensive then why do we even bother to
> > > do it in the tear down path in the first place? Why don't we simply set
> > > a referenced bit on the page to reflect the young pte bit? I might be
> > > missing something here of course.
> > 
> > commit bf3f3bc5e73
> > Author: Nick Piggin <npiggin@suse.de>
> > Date:   Tue Jan 6 14:38:55 2009 -0800
> > 
> >     mm: don't mark_page_accessed in fault path
> > 
> >     Doing a mark_page_accessed at fault-time, then doing SetPageReferenced at
> >     unmap-time if the pte is young has a number of problems.
> > 
> >     mark_page_accessed is supposed to be roughly the equivalent of a young pte
> >     for unmapped references. Unfortunately it doesn't come with any context:
> >     after being called, reclaim doesn't know who or why the page was touched.
> > 
> >     So calling mark_page_accessed not only adds extra lru or PG_referenced
> >     manipulations for pages that are already going to have pte_young ptes anyway,
> >     but it also adds these references which are difficult to work with from the
> >     context of vma specific references (eg. MADV_SEQUENTIAL pte_young may not
> >     wish to contribute to the page being referenced).
> > 
> >     Then, simply doing SetPageReferenced when zapping a pte and finding it is
> >     young, is not a really good solution either. SetPageReferenced does not
> >     correctly promote the page to the active list for example. So after removing
> >     mark_page_accessed from the fault path, several mmap()+touch+munmap() would
> >     have a very different result from several read(2) calls for example, which
> >     is not really desirable.
> 
> Well, I have to say that this is rather vague to me. Nick, could you be
> more specific about which workloads do benefit from this change? Let's
> say that the zapped pte is the only referenced one and then reclaim
> finds the page on inactive list. We would go and reclaim it. But does
> that matter so much? Hot pages would be referenced from multiple ptes
> very likely, no?

As Nick mentioned in the description, without mark_page_accessed in
zapping part, repeated mmap + touch + munmap never acticated the page
while several read(2) calls easily promote it.

