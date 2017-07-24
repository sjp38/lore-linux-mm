Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5F72E6B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 14:12:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i187so4387267wma.15
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 11:12:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 90si4743993wri.179.2017.07.24.11.12.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 11:12:33 -0700 (PDT)
Date: Mon, 24 Jul 2017 20:12:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170724181228.GA27811@dhcp22.suse.cz>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <201707250036.3NQRglrp%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707250036.3NQRglrp%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 25-07-17 00:42:05, kbuild test robot wrote:
> Hi Michal,
> 
> [auto build test ERROR on mmotm/master]
> [also build test ERROR on v4.13-rc2 next-20170724]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Michal-Hocko/mm-oom-allow-oom-reaper-to-race-with-exit_mmap/20170724-233159
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: x86_64-randconfig-x016-201730 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    mm/oom_kill.c: In function '__oom_reap_task_mm':
> >> mm/oom_kill.c:523:9: error: 'ret' undeclared (first use in this function)
>      return ret;
>             ^~~

Fixed by http://lkml.kernel.org/r/20170724152703.GP25221@dhcp22.suse.cz
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
