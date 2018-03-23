Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2986E6B0025
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 05:33:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u133so376145wmf.4
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 02:33:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j204si5817413wmd.113.2018.03.23.02.33.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Mar 2018 02:33:29 -0700 (PDT)
Date: Fri, 23 Mar 2018 10:33:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm: help the ALLOC_HARDER allocation pass the
 watermarki when CMA on
Message-ID: <20180323093327.GM23100@dhcp22.suse.cz>
References: <1521791852-7048-1-git-send-email-zhaoyang.huang@spreadtrum.com>
 <20180323083847.GJ23100@dhcp22.suse.cz>
 <CAGWkznHxTaymoEuFEQ+nN0ZvpPLhdE_fbwpT3pbDf+NQyHw-3g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGWkznHxTaymoEuFEQ+nN0ZvpPLhdE_fbwpT3pbDf+NQyHw-3g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: zhaoyang.huang@spreadtrum.com, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, vel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org

On Fri 23-03-18 17:19:26, Zhaoyang Huang wrote:
> On Fri, Mar 23, 2018 at 4:38 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Fri 23-03-18 15:57:32, Zhaoyang Huang wrote:
> >> For the type of 'ALLOC_HARDER' page allocation, there is an express
> >> highway for the whole process which lead the allocation reach __rmqueue_xxx
> >> easier than other type.
> >> However, when CMA is enabled, the free_page within zone_watermark_ok() will
> >> be deducted for number the pages in CMA type, which may cause the watermark
> >> check fail, but there are possible enough HighAtomic or Unmovable and
> >> Reclaimable pages in the zone. So add 'alloc_harder' here to
> >> count CMA pages in to clean the obstacles on the way to the final.
> >
> > This is no longer the case in the current mmotm tree. Have a look at
> > Joonsoo's zone movable based CMA patchset http://lkml.kernel.org/r/1512114786-5085-1-git-send-email-iamjoonsoo.kim@lge.com
> >
> Thanks for the information. However, I can't find the commit in the
> latest mainline, is it merged?

Not yet. It is still sitting in the mmomt tree. I am not sure what is
the merge plan but I guess it is still waiting for some review feedback.
-- 
Michal Hocko
SUSE Labs
