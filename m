Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 8C0836B0033
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 21:18:10 -0400 (EDT)
Message-ID: <51BA6F34.30001@huawei.com>
Date: Fri, 14 Jun 2013 09:17:40 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 5/9] memcg: use css_get/put when charging/uncharging
 kmem
References: <51B98D17.2050902@huawei.com> <20130613155319.GJ23070@dhcp22.suse.cz>
In-Reply-To: <20130613155319.GJ23070@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

>>  static void memcg_kmem_mark_dead(struct mem_cgroup *memcg)
>>  {
>> +	/*
>> +	 * We need to call css_get() first, because memcg_uncharge_kmem()
>> +	 * will call css_put() if it sees the memcg is dead.
>> +	 */
>> +	smb_wmb();
>>  	if (test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags))
>>  		set_bit(KMEM_ACCOUNTED_DEAD, &memcg->kmem_account_flags);
> 
> I do not feel strongly about that but maybe open coding this in
> mem_cgroup_css_offline would be even better. There is only single caller
> and there is smaller chance somebody will use the function incorrectly
> later on.
> 
> So I leave the decision on you because this doesn't matter much.
> 

Yeah, it should go away soon. I'll post a patch after this patchset gets
merged into -mm tree and then we can discuss there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
