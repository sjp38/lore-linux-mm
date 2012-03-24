Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 2C34D6B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 20:30:07 -0400 (EDT)
Date: Sat, 24 Mar 2012 01:29:58 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg swap: use mem_cgroup_uncharge_swap
Message-ID: <20120324002958.GC1739@cmpxchg.org>
References: <alpine.LSU.2.00.1203231351310.1940@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1203231351310.1940@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Fri, Mar 23, 2012 at 01:54:59PM -0700, Hugh Dickins wrote:
> That stuff __mem_cgroup_commit_charge_swapin() does with a swap entry,
> it has a name and even a declaration: just use mem_cgroup_uncharge_swap().
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
