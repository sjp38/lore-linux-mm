Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 19D536B0044
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 07:21:04 -0500 (EST)
Date: Fri, 9 Nov 2012 13:21:00 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V3] memcg, oom: provide more precise dump info while
 memcg oom happening
Message-ID: <20121109122100.GB5006@dhcp22.suse.cz>
References: <1352389967-23270-1-git-send-email-handai.szj@taobao.com>
 <20121108162539.GP31821@dhcp22.suse.cz>
 <509CD98B.7080503@gmail.com>
 <20121109105040.GA5006@dhcp22.suse.cz>
 <509CF279.1080602@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <509CF279.1080602@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, rientjes@google.com, linux-kernel@vger.kernel.org

On Fri 09-11-12 20:09:29, Sha Zhengju wrote:
> On 11/09/2012 06:50 PM, Michal Hocko wrote:
> >On Fri 09-11-12 18:23:07, Sha Zhengju wrote:
[...]
> >>Another one I'm hesitating is numa stats, it seems the output is
> >>beginning to get more and more....
> >NUMA stats are basically per node - per zone LRU data and that the
> >for(NR_LRU_LISTS) can be easily extended to cover that.
> 
> Yes, the numa_stat cgroup file has done works here. I'll add the numa
> stats if you don't feel improper.

I just described how it can be done, I am not saying it is really
needed. What does per-node information tells you during OOM?
memcg OOM is triggered when we hit the hard limit not when we are not
able to fulfill allocation because of the node restriction.
But maybe your use case would benefit from this...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
