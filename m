Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1D32A6B0036
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 11:47:22 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id cc10so10806394wib.4
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 08:47:21 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id a10si892873wiz.51.2014.06.05.08.47.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 08:47:09 -0700 (PDT)
Message-ID: <539090F1.7090408@nod.at>
Date: Thu, 05 Jun 2014 17:46:57 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] oom: Be less verbose if the oom_control event fd
 has listeners
References: <1401976841-3899-1-git-send-email-richard@nod.at> <1401976841-3899-2-git-send-email-richard@nod.at> <20140605141841.GA23796@redhat.com>
In-Reply-To: <20140605141841.GA23796@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, vdavydov@parallels.com, tj@kernel.org, handai.szj@taobao.com, rientjes@google.com, rusty@rustcorp.com.au, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

Am 05.06.2014 16:18, schrieb Oleg Nesterov:
> On 06/05, Richard Weinberger wrote:
>>
>> +int mem_cgroup_has_listeners(struct mem_cgroup *memcg)
>> +{
>> +	int ret = 0;
>> +
>> +	if (!memcg)
>> +		goto out;
>> +
>> +	spin_lock(&memcg_oom_lock);
>> +	ret = !list_empty(&memcg->oom_notify);
>> +	spin_unlock(&memcg_oom_lock);
>> +
>> +out:
>> +	return ret;
>> +}
> 
> Do we really need memcg_oom_lock to check list_empty() ? With or without
> this lock we can race with list_add/del anyway, and I guess we do not care.

Hmm, in mm/memcontrol.c all list_dev/add are under memcg_oom_lock.
What do I miss?

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
