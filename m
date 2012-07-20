Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 34C8D6B0044
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 18:09:59 -0400 (EDT)
Message-ID: <5009D68C.4020104@parallels.com>
Date: Fri, 20 Jul 2012 19:07:08 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] cgroup: Don't drop the cgroup_mutex in cgroup_rmdir
References: <87ipdjc15j.fsf@skywalker.in.ibm.com> <1342706972-10912-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120719165046.GO24336@google.com> <1342799140.2583.6.camel@twins> <20120720200542.GD21218@google.com>
In-Reply-To: <20120720200542.GD21218@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, liwanp@linux.vnet.ibm.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org

On 07/20/2012 05:05 PM, Tejun Heo wrote:
> Hey, Peter.
> 
> On Fri, Jul 20, 2012 at 05:45:40PM +0200, Peter Zijlstra wrote:
>>> So, Peter, why does cpuset mangle with cgroup_mutex?  What guarantees
>>> does it need?  Why can't it work on "changed" notification while
>>> caching the current css like blkcg does?
>>
>> I've no clue sorry.. /me goes stare at this stuff.. Looks like something
>> Paul Menage did when he created cgroups. I'll have to have a hard look
>> at all that to untangle this. Not something obvious to me.
> 
> Yeah, it would be great if this can be untangled.  I really don't see
> any other reasonable way out of this circular locking mess.  If cpuset
> needs stable css association across certain period, the RTTD is
> caching the css by holding its ref and synchronize modifications to
> that cache, rather than synchronizing cgroup operations themselves.
> 
> Thanks.
> 
IIRC, cpuset can insert a task into an existing cgroup itself. Besides
that, it needs go have a stable vision of the cpumask used by all tasks
in the cgroup.

But this is what I remember from the top of my head, and I am still
officially on vacations....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
