Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id F18D76B05C1
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 02:46:30 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 185so15990447wmk.12
        for <linux-mm@kvack.org>; Sun, 30 Jul 2017 23:46:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f62si3048836wmf.6.2017.07.30.23.46.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 30 Jul 2017 23:46:29 -0700 (PDT)
Date: Mon, 31 Jul 2017 08:46:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: replace TIF_MEMDIE checks by tsk_is_oom_victim
Message-ID: <20170731064625.GB13036@dhcp22.suse.cz>
References: <20170727090357.3205-3-mhocko@kernel.org>
 <201707291609.lv5NwUPI%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707291609.lv5NwUPI%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Sat 29-07-17 16:33:35, kbuild test robot wrote:
> Hi Michal,
> 
> [auto build test ERROR on cgroup/for-next]
> [also build test ERROR on v4.13-rc2 next-20170728]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Michal-Hocko/mm-oom-do-not-rely-on-TIF_MEMDIE-for-memory-reserves-access/20170728-101955
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-next
> config: i386-randconfig-c0-07291424 (attached as .config)
> compiler: gcc-4.9 (Debian 4.9.4-2) 4.9.4
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>    In file included from include/linux/ioport.h:12:0,
>                     from include/linux/device.h:16,
>                     from include/linux/node.h:17,
>                     from include/linux/cpu.h:16,
>                     from kernel/cgroup/cpuset.c:25:
>    kernel/cgroup/cpuset.c: In function '__cpuset_node_allowed':
> >> include/linux/compiler.h:123:18: error: implicit declaration of function 'tsk_is_oom_victim' [-Werror=implicit-function-declaration]

Thanks for the report. We need this
---
commit 638b5ab1ed275f23b52a71941b66c8966d332cd7
Author: Michal Hocko <mhocko@suse.com>
Date:   Mon Jul 31 08:45:53 2017 +0200

    fold me
    
    - fix implicit declaration of function 'tsk_is_oom_victim' reported by
      0day
    
    Signed-off-by: Michal Hocko <mhocko@suse.com>

diff --git a/kernel/cgroup/cpuset.c b/kernel/cgroup/cpuset.c
index 1cc53dff0d94..734ae4fa9775 100644
--- a/kernel/cgroup/cpuset.c
+++ b/kernel/cgroup/cpuset.c
@@ -56,6 +56,7 @@
 #include <linux/time64.h>
 #include <linux/backing-dev.h>
 #include <linux/sort.h>
+#include <linux/oom.h>
 
 #include <linux/uaccess.h>
 #include <linux/atomic.h>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
