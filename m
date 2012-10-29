Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 312B96B006E
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 16:58:11 -0400 (EDT)
Date: Mon, 29 Oct 2012 21:58:06 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [V5 PATCH 08/26] memcontrol: use N_MEMORY instead N_HIGH_MEMORY
Message-ID: <20121029205806.GB21640@dhcp22.suse.cz>
References: <1351523301-20048-1-git-send-email-laijs@cn.fujitsu.com>
 <1351524078-20363-7-git-send-email-laijs@cn.fujitsu.com>
 <20121029162212.GE20757@dhcp22.suse.cz>
 <alpine.DEB.2.00.1210291340100.18552@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1210291340100.18552@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, LKML <linux-kernel@vger.kernel.org>, x86 maintainers <x86@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Rusty Russell <rusty@rustcorp.com.au>, Yinghai Lu <yinghai@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

On Mon 29-10-12 13:40:39, David Rientjes wrote:
> On Mon, 29 Oct 2012, Michal Hocko wrote:
> 
> > > N_HIGH_MEMORY stands for the nodes that has normal or high memory.
> > > N_MEMORY stands for the nodes that has any memory.
> > 
> > What is the difference of those two?
> > 
> 
> Patch 5 in the series 

Strange, I do not see that one at the mailing list.

> introduces it to be equal to N_HIGH_MEMORY, so 

So this is just a rename? If yes it would be much esier if it was
mentioned in the patch description.

> accepting this patch would be an implicit ack of the direction taken 
> there.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
