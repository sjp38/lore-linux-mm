Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 383976B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 14:58:13 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 12 Apr 2012 18:40:32 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3CIpPKC3498218
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 04:51:29 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3CIvr1J008088
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 04:57:54 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v1 0/7] memcg remove pre_destroy
In-Reply-To: <20120412160642.GA13069@google.com>
References: <4F86B9BE.8000105@jp.fujitsu.com> <20120412160642.GA13069@google.com>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Fri, 13 Apr 2012 00:27:42 +0530
Message-ID: <877gxksrq1.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

Tejun Heo <tj@kernel.org> writes:

> Hello, KAMEZAWA.
>
> Thanks a lot for doing this.
>
> On Thu, Apr 12, 2012 at 08:17:18PM +0900, KAMEZAWA Hiroyuki wrote:
>> In recent discussion, Tejun Heo, cgroup maintainer, has a plan to remove
>> ->pre_destroy(). And now, in cgroup tree, pre_destroy() failure cause WARNING.
>
> Just to clarify, I'm not intending to ->pre_destroy() per-se but the
> retry behavior of it, so ->pre_destroy() will be converted to return
> void and called once on rmdir and rmdir will proceed no matter what.
> Also, with the deprecated behavior flag set, pre_destroy() doesn't
> trigger the warning message.
>
> Other than that, if memcg people are fine with the change, I'll be
> happy to route the changes through cgroup/for-3.5 and stack rmdir
> simplification patches on top.
>

Any suggestion on how to take HugeTLB memcg extension patches [1]
upstream. Current patch series I have is on top of cgroup/for-3.5
because I need cgroup_add_files equivalent and cgroup/for-3.5 have
changes around that. So if these memcg patches can also go on top of
cgroup/for-3.5 then I can continue to work on top of cgroup/for-3.5 ?

Can HugeTLB memcg extension patches also go via this tree ? It
should actually got via -mm. But then how do we take care of these
dependencies ?

[1]  http://thread.gmane.org/gmane.linux.kernel.cgroups/1517

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
