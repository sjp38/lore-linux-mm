Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id DCC776B00EA
	for <linux-mm@kvack.org>; Wed, 16 May 2012 02:19:12 -0400 (EDT)
Message-ID: <4FB34653.7060807@parallels.com>
Date: Wed, 16 May 2012 10:16:51 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 11/29] cgroups: ability to stop res charge propagation
 on bounded ancestor
References: <1336758272-24284-1-git-send-email-glommer@parallels.com> <1336758272-24284-12-git-send-email-glommer@parallels.com> <4FB1C6A1.1020602@jp.fujitsu.com>
In-Reply-To: <4FB1C6A1.1020602@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, Frederic Weisbecker <fweisbec@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Aditya Kali <adityakali@google.com>, Oleg Nesterov <oleg@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Tim Hockin <thockin@hockin.org>, Tejun Heo <htejun@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On 05/15/2012 06:59 AM, KAMEZAWA Hiroyuki wrote:
> (2012/05/12 2:44), Glauber Costa wrote:
> 
>> From: Frederic Weisbecker<fweisbec@gmail.com>
>>
>> Moving a task from a cgroup to another may require to substract its
>> resource charge from the old cgroup and add it to the new one.
>>
>> For this to happen, the uncharge/charge propagation can just stop when we
>> reach the common ancestor for the two cgroups.  Further the performance
>> reasons, we also want to avoid to temporarily overload the common
>> ancestors with a non-accurate resource counter usage if we charge first
>> the new cgroup and uncharge the old one thereafter.  This is going to be a
>> requirement for the coming max number of task subsystem.
>>
>> To solve this, provide a pair of new API that can charge/uncharge a
>> resource counter until we reach a given ancestor.
>>
>> Signed-off-by: Frederic Weisbecker<fweisbec@gmail.com>
>> Acked-by: Paul Menage<paul@paulmenage.org>
>> Acked-by: Glauber Costa<glommer@parallels.com>
>> Cc: Li Zefan<lizf@cn.fujitsu.com>
>> Cc: Johannes Weiner<hannes@cmpxchg.org>
>> Cc: Aditya Kali<adityakali@google.com>
>> Cc: Oleg Nesterov<oleg@redhat.com>
>> Cc: Kay Sievers<kay.sievers@vrfy.org>
>> Cc: Tim Hockin<thockin@hockin.org>
>> Cc: Tejun Heo<htejun@gmail.com>
>> Acked-by: Kirill A. Shutemov<kirill@shutemov.name>
>> Signed-off-by: Andrew Morton<akpm@linux-foundation.org>
> 
> 
> Where is this function called in this series ?
> 
> Thanks,
> -Kame
> 
It is not... anymore!
But I forgot the patch among the "pre-requisite" patches I had.

Thanks, this can be dropped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
