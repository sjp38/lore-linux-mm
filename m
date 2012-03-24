Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id D54D26B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 20:26:41 -0400 (EDT)
Date: Sat, 24 Mar 2012 01:26:27 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg swap: mem_cgroup_move_swap_account never needs
 fixup
Message-ID: <20120324002627.GB1739@cmpxchg.org>
References: <alpine.LSU.2.00.1203231348510.1940@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1203231348510.1940@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Fri, Mar 23, 2012 at 01:51:26PM -0700, Hugh Dickins wrote:
> The need_fixup arg to mem_cgroup_move_swap_account() is always false,
> so just remove it.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
