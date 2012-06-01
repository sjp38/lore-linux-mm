Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 27FCF6B0068
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 12:54:44 -0400 (EDT)
Date: Fri, 1 Jun 2012 18:54:37 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] rename MEM_CGROUP_CHARGE_TYPE_MAPPED as
 MEM_CGROUP_CHARGE_TYPE_ANON
Message-ID: <20120601165437.GB1761@cmpxchg.org>
References: <4FC89D22.6020802@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FC89D22.6020802@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mhocko@suse.cz, akpm@linux-foundation.org, cgroups@vger.kernel.org

On Fri, Jun 01, 2012 at 07:44:50PM +0900, Kamezawa Hiroyuki wrote:
> Now, in memcg, 2 "MAPPED" enum/macro are found
>  MEM_CGROUP_CHARGE_TYPE_MAPPED
>  MEM_CGROUP_STAT_FILE_MAPPED
> 
> Their names looks similar to each other but the former is used for
> accounting anonymous memory, the latter is mapped-file.
> (I've received questions caused by this naming issue 3 times..)
> 
> This patch renames MEM_CGROUP_CHARGE_TYPE_MAPPED  as MEM_CGROUP_CHARGE_TYPE_ANON.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
