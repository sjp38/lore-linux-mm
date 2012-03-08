Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id E0EED6B007E
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 22:42:38 -0500 (EST)
Message-ID: <4F582A37.8060802@cn.fujitsu.com>
Date: Thu, 08 Mar 2012 11:40:39 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH] cpuset: mm: Reduce large amounts of memory barrier related
 damage v2
References: <20120306132735.GA2855@suse.de> <4F572730.8000000@cn.fujitsu.com> <20120307112201.GC17697@suse.de>
In-Reply-To: <20120307112201.GC17697@suse.de>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-15
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On wed, 7 Mar 2012 11:22:01 +0000, Mel Gorman wrote:
>> Beside that, we need deal with fork() carefully, or it is possible that the child
>> task will be set to a wrong nodemask.
>>
> 
> Can you clarify this statement please? It's not clear what the old code
> did that protected against problems in fork() versus this patch. fork is
> not calling get_mems_allowed() for example or doing anything special
> around mems_allowed.
> 
> Maybe you are talking about an existing problem whereby during fork
> there should be get_mems_allowed/put_mems_allowed and the mems_allowed
> mask gets copied explicitly?

Yes, If someone updates cpuset's nodemask or cpumask before the child task is attached
into the cpuset cgroup, the child task's nodemask and cpumask can not be updated, just
holds the old mask.

We can fix this problem by seqcounter in a new patch.(It seems the freeze subsystem also
has the same problem)

Thanks
Miao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
