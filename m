Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id CC5956B006C
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 03:20:01 -0400 (EDT)
Date: Wed, 6 Jun 2012 09:19:47 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] remove MEM_CGROUP_CHARGE_TYPE_FORCE
Message-ID: <20120606071947.GE1761@cmpxchg.org>
References: <4FCD609E.8070704@jp.fujitsu.com>
 <4FCD6264.7090905@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FCD6264.7090905@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, akpm@linux-foundation.org

On Tue, Jun 05, 2012 at 10:35:32AM +0900, Kamezawa Hiroyuki wrote:
> 
> There are no users since commit b24028572fb69 "memcg: remove PCG_CACHE"
> 
> Acked-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
