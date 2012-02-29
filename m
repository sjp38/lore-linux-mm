Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 0D01B6B007E
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 00:42:07 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9AADF3EE0C0
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:42:06 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 76B1445DEB4
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:42:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E9E345DEB7
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:42:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 335A1E08004
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:42:06 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DE35A1DB803B
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:42:05 +0900 (JST)
Date: Wed, 29 Feb 2012 14:40:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH next] memcg: remove PCG_FILE_MAPPED fix cosmetic fix
Message-Id: <20120229144037.19ec6efa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1202282127110.4875@eggly.anvils>
References: <alpine.LSU.2.00.1202282121160.4875@eggly.anvils>
	<alpine.LSU.2.00.1202282127110.4875@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 28 Feb 2012 21:28:40 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> mem_cgroup_move_account() begins with "anon = PageAnon(page)", and
> then anon is used thereafter: testing PageAnon(page) in the middle
> makes the reader wonder if there's some race to guard against - no.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Thanks.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
> 
>  mm/memcontrol.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- 3.3-rc5-next/mm/memcontrol.c	2012-02-27 09:56:59.072001463 -0800
> +++ linux/mm/memcontrol.c	2012-02-28 20:45:43.488100423 -0800
> @@ -2560,7 +2560,7 @@ static int mem_cgroup_move_account(struc
>  
>  	move_lock_mem_cgroup(from, &flags);
>  
> -	if (!PageAnon(page) && page_mapped(page)) {
> +	if (!anon && page_mapped(page)) {
>  		/* Update mapped_file data for mem_cgroup */
>  		preempt_disable();
>  		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
