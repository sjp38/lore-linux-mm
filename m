Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 2F3CD6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 23:13:13 -0400 (EDT)
Message-ID: <51638709.207@huawei.com>
Date: Tue, 9 Apr 2013 11:12:09 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/8] cgroup: implement cgroup_from_id()
References: <51627DA9.7020507@huawei.com> <51627DEB.4090104@huawei.com> <20130408154319.GD3021@htj.dyndns.org>
In-Reply-To: <20130408154319.GD3021@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On 2013/4/8 23:43, Tejun Heo wrote:
> On Mon, Apr 08, 2013 at 04:20:59PM +0800, Li Zefan wrote:
>> +/**
>> + * cgroup_from_id - lookup cgroup by id
>> + * @ss: cgroup subsys to be looked into.
>> + * @id: the id
>> + *
>> + * Returns pointer to cgroup if there is valid one with id.
>> + * NULL if not. Should be called under rcu_read_lock()
>> + */
>> +struct cgroup *cgroup_from_id(struct cgroup_subsys *ss, int id)
>> +{
> 
> 	rcu_lockdep_assert(rcu_read_lock_held(), ..
.);

will update

> 
>> +	return idr_find(&ss->root->cgroup_idr, id);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
