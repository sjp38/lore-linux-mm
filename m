Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 78A2C6B0006
	for <linux-mm@kvack.org>; Sun, 14 Apr 2013 20:39:11 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id c10so5257916ieb.3
        for <linux-mm@kvack.org>; Sun, 14 Apr 2013 17:39:10 -0700 (PDT)
Message-ID: <516B4C2A.5010400@gmail.com>
Date: Mon, 15 Apr 2013 08:39:06 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] Beyond NUMA
References: <9f091f23-9314-422c-9f97-525ddefd483b@default>
In-Reply-To: <9f091f23-9314-422c-9f97-525ddefd483b@default>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: lsf@lists.linux-foundation.org, linux-mm@kvack.org

Hi Dan,
On 04/12/2013 08:29 AM, Dan Magenheimer wrote:
> MM developers and all --
>
> It's a bit late to add a topic, but with such a great group of brains
> together, it seems worthwhile to spend at least some time speculating
> on "farther-out" problems.  So I propose for the MM track:
>
> Beyond NUMA
>
> NUMA now impacts even the smallest servers and soon, perhaps even embedded
> systems, but the performance effects are limited when the number of nodes
> is small (e.g. two).  As the number of nodes grows, along with the number
> of memory controllers, NUMA can have a big performance impact and the MM
> community has invested a huge amount of energy into reducing this problem.
>
> But as the number of memory controllers grows, the cost of the system
> grows faster.  This is classic "scale-up" and certain workloads will
> always benefit from having as many CPUs/cores and nodes as can be
> packed into a single system.  System vendors are happy to oblige because the
> profit margin on scale-out systems can be proportionally much much
> larger than on smaller commodity systems.  So the NUMA work will always
> be necessary and important.
>
> But as scale-out grows to previously unimaginable levels, an increasing
> fraction of workloads are unable to adequately benefit to compensate
> for the non-linear increase in system cost.  And so more users, especially
> cost-sensitive users, are turning instead to scale-out to optimize
> cost vs benefit for their massive data centers.  Recent examples include
> HP's Moonshot and Facebook's "Group Hug".  And even major data center
> topology changes are being proposed which use super-high-speed links to
> separate CPUs from RAM [1].
>
> While filesystems and storage have long ago adapted to handle large
> numbers of servers effectively, the MM subsystem is still isolated,
> managing its own private set of RAM, independent of and completely
> partitioned from the RAM of other servers.  Perhaps we, the Linux
> MM developers, should start considering how MM can evolve in this
> new world.  In some ways, scale-out is like NUMA, but a step beyond.
> In other ways, scale-out is very different.  The ramster project [2]
> in the staging tree is a step in the direction of "clusterizing" RAM,
> but may or may not be the right step.

If I configure UMA machine to fake numa, is there benefit or impact 
performance?

>
> Discuss.
>
> [1] http://allthingsd.com/20130410/intel-wants-to-redesign-your-server-rack/
> [2] http://lwn.net/Articles/481681/
>
> (see y'all next week!)
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
