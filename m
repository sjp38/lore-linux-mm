Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7276B011F
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 11:46:16 -0500 (EST)
Message-ID: <49B153A3.8090906@oracle.com>
Date: Fri, 06 Mar 2009 08:47:31 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 3/3] memcg documenation soft limit (Yet Another One)
References: <20090306092323.21063.93169.sendpatchset@localhost.localdomain>	<20090306185440.66b92ca3.kamezawa.hiroyu@jp.fujitsu.com>	<20090306193438.8084837d.kamezawa.hiroyu@jp.fujitsu.com> <20090306193821.ca2fb628.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090306193821.ca2fb628.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Documentation for softlimit (3/3)
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  Documentation/cgroups/memory.txt |   19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
> 
> Index: mmotm-2.6.29-Mar3/Documentation/cgroups/memory.txt
> ===================================================================
> --- mmotm-2.6.29-Mar3.orig/Documentation/cgroups/memory.txt
> +++ mmotm-2.6.29-Mar3/Documentation/cgroups/memory.txt
> @@ -322,6 +322,25 @@ will be charged as a new owner of it.
>    - a cgroup which uses hierarchy and it has child cgroup.
>    - a cgroup which uses hierarchy and not the root of hierarchy.
>  
> +5.4 softlimit
> +  Memory cgroup supports softlimit and has 2 params for control.

                                                parameters

> +    - memory.softlimit_in_bytes
> +	- softlimit to this cgroup.
         softlimit for this cgroup
		(i.e., no beginning '-' and no ending '.')


> +    - memory.softlimit_priority.
> +	- priority of this cgroup at softlimit reclaim.
	 priority of this cgroup at softlimit reclaim

> +	  Allowed priority level is 3-0 and 3 is the lowest.

	Not very user friendly...

> +	  If 0, this cgroup will not be target of softlimit.
> +
> +  At memory shortage of the system (or local node/zone), softlimit helps
> +  kswapd(), a global memory recalim kernel thread, and inform victim cgroup

                               reclaim                    informs

> +  to be shrinked to kswapd.
> +
> +  Victim selection logic:
> +  The kernel searches from the lowest priroty(3) up to the highest(1).

                                         priority                     0 ?? (from above)

> +  If it find a cgroup witch has memory larger than softlimit, steal memory

           finds         which

> +  from it.
> +  If multiple cgroups are on the same priority, each cgroup wil be a

                                                               will

> +  victim in turn.
>  
>  6. Hierarchy support


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
