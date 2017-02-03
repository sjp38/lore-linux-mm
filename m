Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE53F6B0253
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 09:59:53 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id kq3so5464165wjc.1
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 06:59:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l8si32763191wrb.169.2017.02.03.06.59.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Feb 2017 06:59:52 -0800 (PST)
Date: Fri, 3 Feb 2017 15:59:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2 v3] mm: vmscan: do not pass reclaimed slab to
 vmpressure
Message-ID: <20170203145947.GD19325@dhcp22.suse.cz>
References: <1485504817-3124-1-git-send-email-vinmenon@codeaurora.org>
 <1485853328-7672-1-git-send-email-vinmenon@codeaurora.org>
 <20170202104422.GF22806@dhcp22.suse.cz>
 <20170202104808.GG22806@dhcp22.suse.cz>
 <CAOaiJ-nyZtgrCHjkGJeG3nhGFes5Y7go3zZwa3SxGrZV=LV0ag@mail.gmail.com>
 <20170202115222.GH22806@dhcp22.suse.cz>
 <CAOaiJ-=pCUzaVbte-+QiQoN_XtB0KFbcB40yjU9r7OV8VOkmFg@mail.gmail.com>
 <20170202160145.GK22806@dhcp22.suse.cz>
 <CAOaiJ-=O_SkaYry4Lay8LidvC11sTukchE_p6P4mKm=fgJz1Dg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOaiJ-=O_SkaYry4Lay8LidvC11sTukchE_p6P4mKm=fgJz1Dg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vinayak menon <vinayakm.list@gmail.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Minchan Kim <minchan@kernel.org>, shashim@codeaurora.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Fri 03-02-17 10:56:42, vinayak menon wrote:
> On Thu, Feb 2, 2017 at 9:31 PM, Michal Hocko <mhocko@kernel.org> wrote:
> >
> > Why would you like to chose and kill a task when the slab reclaim can
> > still make sufficient progres? Are you sure that the slab contribution
> > to the stats makes all the above happening?
> >
> I agree that a task need not be killed if sufficient progress is made
> in reclaiming
> memory say from slab. But here it looks like we have an impact because of just
> increasing the reclaimed without touching the scanned. It could be because of
> disimilar costs or not adding adding cost. I agree that vmpressure is
> only a reasonable
> estimate which does not already include few other costs, but I am not
> sure whether it is ok
> to add another element which further increases that disparity.
> We noticed this problem when moving from 3.18 to 4.4 kernel version. With the
> same workload, the vmpressure events differ between 3.18 and 4.4 causing the
> above mentioned problem. And with this patch on 4.4 we get the same results
> as in 3,18. So the slab contribution to stats is making a difference.

Please document that in the changelog along with description of the
workload that is affected. Ideally also add some data from /proc/vmstat
so that we can see the reclaim activity.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
