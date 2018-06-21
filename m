Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5958A6B0006
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 06:59:25 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w1-v6so1128057pgr.7
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 03:59:25 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l3-v6si3677734pgp.345.2018.06.21.03.59.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 03:59:24 -0700 (PDT)
Date: Thu, 21 Jun 2018 18:58:48 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [patch v2] mm, oom: fix unnecessary killing of additional
 processes
Message-ID: <201806211834.NQ5KvllA%fengguang.wu@intel.com>
References: <alpine.DEB.2.21.1806201458540.14059@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1806201458540.14059@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi David,

I love your patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[also build test WARNING on v4.18-rc1 next-20180621]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/David-Rientjes/mm-oom-fix-unnecessary-killing-of-additional-processes/20180621-060118
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/nodemask.h:265:16: sparse: expression using sizeof(void)
   include/linux/nodemask.h:271:16: sparse: expression using sizeof(void)
   include/linux/nodemask.h:265:16: sparse: expression using sizeof(void)
   include/linux/nodemask.h:271:16: sparse: expression using sizeof(void)
>> mm/oom_kill.c:656:5: sparse: symbol 'oom_free_timeout_ms' was not declared. Should it be static?
   include/linux/rcupdate.h:683:9: sparse: context imbalance in 'find_lock_task_mm' - wrong count at exit
   include/linux/sched/mm.h:141:37: sparse: dereference of noderef expression
   mm/oom_kill.c:218:28: sparse: context imbalance in 'oom_badness' - unexpected unlock
   mm/oom_kill.c:398:9: sparse: context imbalance in 'dump_tasks' - different lock contexts for basic block
   include/linux/rcupdate.h:683:9: sparse: context imbalance in 'oom_kill_process' - unexpected unlock

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
