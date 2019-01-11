Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id CDEA28E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 19:23:51 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id x7so7170633pll.23
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:23:51 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id d16si201256pfn.169.2019.01.10.16.23.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 16:23:50 -0800 (PST)
Subject: Re: [kbuild-all] [PATCH 2/2] memcg: do not report racy no-eligible
 OOM tasks
References: <20190107143802.16847-3-mhocko@kernel.org>
 <201901081642.Q6tXklr0%fengguang.wu@intel.com>
 <20190108093959.GQ31793@dhcp22.suse.cz>
From: Rong Chen <rong.a.chen@intel.com>
Message-ID: <a0312c1e-dfed-5cff-c660-e1c1bea9843b@intel.com>
Date: Fri, 11 Jan 2019 08:23:57 +0800
MIME-Version: 1.0
In-Reply-To: <20190108093959.GQ31793@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, kbuild test robot <lkp@intel.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>



On 01/08/2019 05:39 PM, Michal Hocko wrote:
> On Tue 08-01-19 16:35:42, kbuild test robot wrote:
> [...]
>> All warnings (new ones prefixed by >>):
>>
>>     include/linux/rcupdate.h:659:9: warning: context imbalance in 'find_lock_task_mm' - wrong count at exit
>>     include/linux/sched/mm.h:141:37: warning: dereference of noderef expression
>>     mm/oom_kill.c:225:28: warning: context imbalance in 'oom_badness' - unexpected unlock
>>     mm/oom_kill.c:406:9: warning: context imbalance in 'dump_tasks' - different lock contexts for basic block
>>>> mm/oom_kill.c:918:17: warning: context imbalance in '__oom_kill_process' - unexpected unlock
> What exactly does this warning say? I do not see anything wrong about
> the code. find_lock_task_mm returns a locked task when t != NULL and
> mark_oom_victim doesn't do anything about the locking. Am I missing
> something or the warning is just confused?

Thanks for your reply. It looks like a false positive. We'll look into it.

Best Regards,
Rong Chen

>
> [...]
>> 00508538 Michal Hocko          2019-01-07  915  		t = find_lock_task_mm(p);
>> 00508538 Michal Hocko          2019-01-07  916  		if (!t)
>> 00508538 Michal Hocko          2019-01-07  917  			continue;
>> 00508538 Michal Hocko          2019-01-07 @918  		mark_oom_victim(t);
>> 00508538 Michal Hocko          2019-01-07  919  		task_unlock(t);
>> 647f2bdf David Rientjes        2012-03-21  920  	}
