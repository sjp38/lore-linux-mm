Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 943B66B0265
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 05:29:38 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y84so85054828lfc.3
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 02:29:38 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id gx6si16321659wjb.76.2016.04.29.02.29.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 02:29:37 -0700 (PDT)
Received: by mail-wm0-f47.google.com with SMTP id e201so19924541wme.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 02:29:37 -0700 (PDT)
Date: Fri, 29 Apr 2016 11:29:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LKP] [lkp] [mm, oom] faad2185f4: vm-scalability.throughput
 -11.8% regression
Message-ID: <20160429092936.GE21977@dhcp22.suse.cz>
References: <20160427073617.GA2179@dhcp22.suse.cz>
 <87fuu7iht0.fsf@yhuang-dev.intel.com>
 <20160427083733.GE2179@dhcp22.suse.cz>
 <87bn4vigpc.fsf@yhuang-dev.intel.com>
 <20160427091718.GG2179@dhcp22.suse.cz>
 <20160428051659.GA10843@aaronlu.sh.intel.com>
 <20160428085702.GB31489@dhcp22.suse.cz>
 <e7bfca34-2f7b-290f-0638-4ab1794b9fbd@intel.com>
 <20160428112135.GD31489@dhcp22.suse.cz>
 <20160429085937.GA20922@aaronlu.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160429085937.GA20922@aaronlu.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, kernel test robot <xiaolong.ye@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, lkp@01.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Fri 29-04-16 16:59:37, Aaron Lu wrote:
> On Thu, Apr 28, 2016 at 01:21:35PM +0200, Michal Hocko wrote:
> > All of them are order-2 and this was a known problem for "mm, oom:
> > rework oom detection" commit and later should make it much more
> > resistant to failures for higher (!costly) orders. So I would definitely
> > encourage you to retest with the current _complete_ mmotm tree.
> 
> OK, will run the test on this branch:
> https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-4.5
> with head commit:
> commit 81cc2e6f1e8bd81ebc7564a3cd3797844ee1712e
> Author: Michal Hocko <mhocko@suse.com>
> Date:   Thu Apr 28 12:03:24 2016 +0200
> 
>     drm/amdgpu: make amdgpu_mn_get wait for mmap_sem killable
> 
> Please let me know if this isn't right.

Yes that should contain all the oom related patches in the mmotm tree.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
