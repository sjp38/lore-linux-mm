Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 27B9D6B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 10:52:06 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id i6so546917oih.1
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 07:52:06 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p25sor6268421oie.207.2017.09.13.07.52.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Sep 2017 07:52:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d677d23a-9b1d-e3fd-9ff2-bac8cccfb200@suse.cz>
References: <alpine.LRH.2.02.1709110231010.3666@file01.intranet.prod.int.rdu2.redhat.com>
 <20170911082650.dqfirwc63xy7i33q@dhcp22.suse.cz> <alpine.LRH.2.02.1709111926480.31898@file01.intranet.prod.int.rdu2.redhat.com>
 <d677d23a-9b1d-e3fd-9ff2-bac8cccfb200@suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 13 Sep 2017 07:52:02 -0700
Message-ID: <CALvZod7J+0iVkto_JkTqWFo0wfVfHdEXps+Pt7pGAxDCMDkDwQ@mail.gmail.com>
Subject: Re: [PATCH] mm: respect the __GFP_NOWARN flag when warning about stalls
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

>
> We would have to consider (instead of jiffies) the time the process was
> either running, or waiting on something that's related to memory
> allocation/reclaim (page lock etc.). I.e. deduct the time the process
> was runable but there was no available cpu. I expect however that such
> level of detail wouldn't be feasible here, though?
>

Johannes' memdelay work (once merged) might be useful here. I think
memdalay can differentiate between an allocating process getting
delayed due to preemption or due to unsuccessful reclaim/compaction.
If the delay is due to unsuccessful reclaim/compaction then we should
warn here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
