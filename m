Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 1D7EA6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 20:14:06 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1BB563EE0BC
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 09:14:04 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0257645DE59
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 09:14:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DE7A345DE56
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 09:14:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CC0A01DB8051
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 09:14:03 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 82EC91DB804A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 09:14:03 +0900 (JST)
Message-ID: <4FECF2B4.5040500@jp.fujitsu.com>
Date: Fri, 29 Jun 2012 09:11:32 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
References: <2a1a74bf-fbb5-4a6e-b958-44fff8debff2@zmail13.collab.prod.int.phx2.redhat.com> <34bb8049-8007-496c-8ffb-11118c587124@zmail13.collab.prod.int.phx2.redhat.com> <20120627154827.GA4420@tiehlicka.suse.cz> <alpine.DEB.2.00.1206271256120.22162@chino.kir.corp.google.com> <20120628123611.GA16042@tiehlicka.suse.cz> <20120628182934.GD22641@google.com>
In-Reply-To: <20120628182934.GD22641@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, Zhouping Liu <zliu@redhat.com>, linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>, CAI Qian <caiqian@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, aneesh.kumar@linux.vnet.ibm.com

(2012/06/29 3:29), Tejun Heo wrote:
> Hello, Michal.
>
> On Thu, Jun 28, 2012 at 02:36:11PM +0200, Michal Hocko wrote:
>> @@ -2726,6 +2726,9 @@ static int cgroup_addrm_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
>>   	int err, ret = 0;
>>
>>   	for (cft = cfts; cft->name[0] != '\0'; cft++) {
>> +		if (subsys->cftype_enabled && !subsys->cftype_enabled(cft->name))
>> +			continue;
>> +
>>   		if (is_add)
>>   			err = cgroup_add_file(cgrp, subsys, cft);
>>   		else
>
> I hope we could avoid this dynamic decision.  That was one of the main
> reasons behind doing the cftype thing.  It's better to be able to
> "declare" these kind of things rather than being able to implement
> fully flexible dynamic logic.  Too much flexibility often doesn't
> achieve much while being a hindrance to evolution of code base (trying
> to improve / simplify X - ooh... there's this single wacko corner case
> YYY here which is really different from all other users).
>
> really_do_swap_account can't change once booted, right?  Why not just
> separate out memsw cfts into a separate array and call
> cgroup_add_cftypes() from init path?  Can't we do that from
> enable_swap_cgroup()?
>

Yes, that's will be good.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
