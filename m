Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id B76BC6B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 04:10:46 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 393CF3EE0C0
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 17:10:45 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 208BD45DE51
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 17:10:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 09D3445DE4E
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 17:10:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EFAFEE08005
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 17:10:44 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A110FE08001
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 17:10:44 +0900 (JST)
Message-ID: <500911EA.1030004@jp.fujitsu.com>
Date: Fri, 20 Jul 2012 17:08:10 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: + hugetlb-cgroup-simplify-pre_destroy-callback.patch added to
 -mm tree
References: <20120718212637.133475C0050@hpza9.eem.corp.google.com> <20120719113915.GC2864@tiehlicka.suse.cz> <87r4s8gcwe.fsf@skywalker.in.ibm.com> <20120719123820.GG2864@tiehlicka.suse.cz> <87ipdjc15j.fsf@skywalker.in.ibm.com> <5008AEC2.9090707@jp.fujitsu.com> <5008B25D.5000902@jp.fujitsu.com> <20120720080136.GB12434@tiehlicka.suse.cz>
In-Reply-To: <20120720080136.GB12434@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, liwanp@linux.vnet.ibm.com, Tejun Heo <htejun@gmail.com>, Li Zefan <lizefan@huawei.com>, cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org

(2012/07/20 17:01), Michal Hocko wrote:
> On Fri 20-07-12 10:20:29, KAMEZAWA Hiroyuki wrote:
> [...]
>> Hmm, can't cgroup_lock() be implemented as
>>
>>
>> void cgroup_lock()
>> {
>> 	get_online_cpus()
>> 	lock_memory_hotplug()
>> 	mutex_lock(&cgroup_mutex);
>> }
>
> This is really ugly and it wouldn't help much anyway. Notifier which
> takes the cgroup_lock is called when cpu_hotplug.lock is held already.

Hm ? IIUC, notifer will not work until put_online_cpu() is called.

> You would need to call cgroup_lock() before taking the cpu_hotplug.lock
> and remove it from notifiers. I think this should be doable but I didn't
> have too much time to look deeper into it.
>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
