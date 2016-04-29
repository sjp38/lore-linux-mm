Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8F56B025F
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 04:59:43 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id vv3so158794619pab.2
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 01:59:43 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id l124si7198847pfl.154.2016.04.29.01.59.42
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 01:59:42 -0700 (PDT)
Date: Fri, 29 Apr 2016 16:59:37 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [LKP] [lkp] [mm, oom] faad2185f4: vm-scalability.throughput
 -11.8% regression
Message-ID: <20160429085937.GA20922@aaronlu.sh.intel.com>
References: <20160427031556.GD29014@yexl-desktop>
 <20160427073617.GA2179@dhcp22.suse.cz>
 <87fuu7iht0.fsf@yhuang-dev.intel.com>
 <20160427083733.GE2179@dhcp22.suse.cz>
 <87bn4vigpc.fsf@yhuang-dev.intel.com>
 <20160427091718.GG2179@dhcp22.suse.cz>
 <20160428051659.GA10843@aaronlu.sh.intel.com>
 <20160428085702.GB31489@dhcp22.suse.cz>
 <e7bfca34-2f7b-290f-0638-4ab1794b9fbd@intel.com>
 <20160428112135.GD31489@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160428112135.GD31489@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, kernel test robot <xiaolong.ye@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, lkp@01.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Thu, Apr 28, 2016 at 01:21:35PM +0200, Michal Hocko wrote:
> All of them are order-2 and this was a known problem for "mm, oom:
> rework oom detection" commit and later should make it much more
> resistant to failures for higher (!costly) orders. So I would definitely
> encourage you to retest with the current _complete_ mmotm tree.

OK, will run the test on this branch:
https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-4.5
with head commit:
commit 81cc2e6f1e8bd81ebc7564a3cd3797844ee1712e
Author: Michal Hocko <mhocko@suse.com>
Date:   Thu Apr 28 12:03:24 2016 +0200

    drm/amdgpu: make amdgpu_mn_get wait for mmap_sem killable

Please let me know if this isn't right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
