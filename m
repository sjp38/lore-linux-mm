Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2846B0005
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 09:01:01 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e201so20007857wme.1
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 06:01:01 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id g129si4110018wmd.47.2016.04.29.06.00.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 06:00:56 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n129so4956264wmn.1
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 06:00:56 -0700 (PDT)
Date: Fri, 29 Apr 2016 15:00:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LKP] [lkp] [mm, oom] faad2185f4: vm-scalability.throughput
 -11.8% regression
Message-ID: <20160429130055.GN21977@dhcp22.suse.cz>
References: <20160427083733.GE2179@dhcp22.suse.cz>
 <87bn4vigpc.fsf@yhuang-dev.intel.com>
 <20160427091718.GG2179@dhcp22.suse.cz>
 <20160428051659.GA10843@aaronlu.sh.intel.com>
 <20160428085702.GB31489@dhcp22.suse.cz>
 <e7bfca34-2f7b-290f-0638-4ab1794b9fbd@intel.com>
 <20160428112135.GD31489@dhcp22.suse.cz>
 <20160429085937.GA20922@aaronlu.sh.intel.com>
 <20160429092936.GE21977@dhcp22.suse.cz>
 <20160429125413.GA21824@aaronlu.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160429125413.GA21824@aaronlu.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, kernel test robot <xiaolong.ye@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, lkp@01.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Fri 29-04-16 20:54:13, Aaron Lu wrote:
> On Fri, Apr 29, 2016 at 11:29:36AM +0200, Michal Hocko wrote:
> > On Fri 29-04-16 16:59:37, Aaron Lu wrote:
> > > On Thu, Apr 28, 2016 at 01:21:35PM +0200, Michal Hocko wrote:
> > > > All of them are order-2 and this was a known problem for "mm, oom:
> > > > rework oom detection" commit and later should make it much more
> > > > resistant to failures for higher (!costly) orders. So I would definitely
> > > > encourage you to retest with the current _complete_ mmotm tree.
> > > 
> > > OK, will run the test on this branch:
> > > https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-4.5
> > > with head commit:
> > > commit 81cc2e6f1e8bd81ebc7564a3cd3797844ee1712e
> > > Author: Michal Hocko <mhocko@suse.com>
> > > Date:   Thu Apr 28 12:03:24 2016 +0200
> > > 
> > >     drm/amdgpu: make amdgpu_mn_get wait for mmap_sem killable
> > > 
> > > Please let me know if this isn't right.
> > 
> > Yes that should contain all the oom related patches in the mmotm tree.
> 
> The test shows commit 81cc2e6f1e doesn't OOM anymore and its throughput 
> is 43609, the same level compared to 43802, so everyting is fine :-)

Thanks a lot for double checking! This is highly appreciated!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
