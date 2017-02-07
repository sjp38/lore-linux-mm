Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B200B6B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 09:53:00 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id kq3so26124938wjc.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 06:53:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 31si5279362wrj.324.2017.02.07.06.52.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 06:52:59 -0800 (PST)
Date: Tue, 7 Feb 2017 15:52:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2 v4] mm: vmscan: do not pass reclaimed slab to
 vmpressure
Message-ID: <20170207145257.GT5065@dhcp22.suse.cz>
References: <1486383850-30444-1-git-send-email-vinmenon@codeaurora.org>
 <20170206125240.GB10298@dhcp22.suse.cz>
 <CAOaiJ-=ovwZ53nqNLRtP=sCY=+4s1-1r_soBXvam42bxDeUdAQ@mail.gmail.com>
 <20170207081002.GB5065@dhcp22.suse.cz>
 <CAOaiJ-ndDnkm2qL0M9gqhnR8szzDxiRG2_KkaYAM+9hAkq_m5A@mail.gmail.com>
 <20170207121744.GM5065@dhcp22.suse.cz>
 <CAOaiJ-=B7d9uAkXPdA-F2NFtY4p43xQPG4Pozv3NY9BahFaO3A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOaiJ-=B7d9uAkXPdA-F2NFtY4p43xQPG4Pozv3NY9BahFaO3A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vinayak menon <vinayakm.list@gmail.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Minchan Kim <minchan@kernel.org>, shashim@codeaurora.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Tue 07-02-17 18:46:55, vinayak menon wrote:
> On Tue, Feb 7, 2017 at 5:47 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Tue 07-02-17 16:39:15, vinayak menon wrote:
[...]
> >> Starting to kill at the right time helps in recovering memory at a
> >> faster rate than waiting for the reclaim to complete. Yes, we may
> >> be able to modify lowmemorykiller to cope with this problem. But
> >> the actual problem this patch tried to fix was the vmpressure event
> >> regression.
> >
> > I am not happy about the regression but you should try to understand
> > that we might end up with another report a month later for a different
> > consumer of events.
>
> I understand that. But this was the way vmpressure had worked until the
> regression and IMHO adding reclaimed slab just increases the noise in
> vmpressure.

I would argue the previous behavior was wrong as well.

> > I believe that the vmpressure needs some serious rethought and come with
> > a more realistic and stable metric.
>
> Okay. I agree. So you are suggesting to drop the patch ?

Unless there is a strong reason to keep it. Your test case seems to be
rather artificial and the behavior is not much better after your patch.
So rather than tunning the broken behavior for a particular test case
I would welcome rethinking the whole thing.

That being said I am not nacking the patch so if others think that this
is a reasonable thing to do for now I will not stand in the way.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
