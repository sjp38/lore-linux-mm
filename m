Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id D16C86B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 21:47:02 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id ph11so2063633igc.1
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 18:47:02 -0800 (PST)
Received: from mgwym02.jp.fujitsu.com (mgwym02.jp.fujitsu.com. [211.128.242.41])
        by mx.google.com with ESMTPS id k65si4199612iok.56.2015.12.16.18.47.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 18:47:01 -0800 (PST)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 7CDC7AC01CA
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 11:46:52 +0900 (JST)
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
 <20151214153037.GB4339@dhcp22.suse.cz> <20151214194258.GH28521@esperanza>
 <566F8781.80108@jp.fujitsu.com> <20151215145011.GA20355@cmpxchg.org>
 <5670D806.60408@jp.fujitsu.com> <20151216110912.GA29816@cmpxchg.org>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <56722203.5030604@jp.fujitsu.com>
Date: Thu, 17 Dec 2015 11:46:27 +0900
MIME-Version: 1.0
In-Reply-To: <20151216110912.GA29816@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2015/12/16 20:09, Johannes Weiner wrote:
> On Wed, Dec 16, 2015 at 12:18:30PM +0900, Kamezawa Hiroyuki wrote:
>> Hmm, my requests are
>>   - set the same capabilities as mlock() to set swap.limit=0
>
> Setting swap.max is already privileged operation.
>
Sure.

>>   - swap-full notification via vmpressure or something mechanism.
>
> Why?
>

I think it's a sign of unhealthy condition, starting file cache drop rate to rise.
But I forgot that there are resource threshold notifier already. Does the notifier work
for swap.usage ?

>>   - OOM-Killer's available memory calculation may be corrupted, please check.
>
> Vladimir updated mem_cgroup_get_limit().
>
I'll check it.

>>   - force swap-in at reducing swap.limit
>
> Why?
>
If full, swap.limit cannot be reduced even if there are available memory in a cgroup.
Another cgroup cannot make use of the swap resource while it's occupied by other cgroup.
The job scheduler should have a chance to fix the situation.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
