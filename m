Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 492C36B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 16:40:42 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so2813652dad.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 13:40:41 -0700 (PDT)
Date: Mon, 29 Oct 2012 13:40:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [V5 PATCH 08/26] memcontrol: use N_MEMORY instead
 N_HIGH_MEMORY
In-Reply-To: <20121029162212.GE20757@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.00.1210291340100.18552@chino.kir.corp.google.com>
References: <1351523301-20048-1-git-send-email-laijs@cn.fujitsu.com> <1351524078-20363-7-git-send-email-laijs@cn.fujitsu.com> <20121029162212.GE20757@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, LKML <linux-kernel@vger.kernel.org>, x86 maintainers <x86@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Rusty Russell <rusty@rustcorp.com.au>, Yinghai Lu <yinghai@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

On Mon, 29 Oct 2012, Michal Hocko wrote:

> > N_HIGH_MEMORY stands for the nodes that has normal or high memory.
> > N_MEMORY stands for the nodes that has any memory.
> 
> What is the difference of those two?
> 

Patch 5 in the series introduces it to be equal to N_HIGH_MEMORY, so 
accepting this patch would be an implicit ack of the direction taken 
there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
