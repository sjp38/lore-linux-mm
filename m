Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id EEA396B000E
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 16:04:10 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w5-v6so8243764plz.23
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 13:04:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 73si5357482pfz.20.2018.03.23.13.04.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 13:04:09 -0700 (PDT)
Date: Fri, 23 Mar 2018 13:04:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1] mm: help the ALLOC_HARDER allocation pass the
 watermarki when CMA on
Message-Id: <20180323130408.0c6451fac02c49b535ec7485@linux-foundation.org>
In-Reply-To: <20180323093327.GM23100@dhcp22.suse.cz>
References: <1521791852-7048-1-git-send-email-zhaoyang.huang@spreadtrum.com>
	<20180323083847.GJ23100@dhcp22.suse.cz>
	<CAGWkznHxTaymoEuFEQ+nN0ZvpPLhdE_fbwpT3pbDf+NQyHw-3g@mail.gmail.com>
	<20180323093327.GM23100@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, zhaoyang.huang@spreadtrum.com, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, vel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 23 Mar 2018 10:33:27 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 23-03-18 17:19:26, Zhaoyang Huang wrote:
> > On Fri, Mar 23, 2018 at 4:38 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > > On Fri 23-03-18 15:57:32, Zhaoyang Huang wrote:
> > >> For the type of 'ALLOC_HARDER' page allocation, there is an express
> > >> highway for the whole process which lead the allocation reach __rmqueue_xxx
> > >> easier than other type.
> > >> However, when CMA is enabled, the free_page within zone_watermark_ok() will
> > >> be deducted for number the pages in CMA type, which may cause the watermark
> > >> check fail, but there are possible enough HighAtomic or Unmovable and
> > >> Reclaimable pages in the zone. So add 'alloc_harder' here to
> > >> count CMA pages in to clean the obstacles on the way to the final.
> > >
> > > This is no longer the case in the current mmotm tree. Have a look at
> > > Joonsoo's zone movable based CMA patchset http://lkml.kernel.org/r/1512114786-5085-1-git-send-email-iamjoonsoo.kim@lge.com
> > >
> > Thanks for the information. However, I can't find the commit in the
> > latest mainline, is it merged?
> 
> Not yet. It is still sitting in the mmomt tree. I am not sure what is
> the merge plan but I guess it is still waiting for some review feedback.

http://lkml.kernel.org/r/20171222001113.GA1729@js1304-P5Q-DELUXE

That patchset has been floating about since December and still has
unresolved issues.

Joonsoo, can you please let us know the status?

Thanks.
