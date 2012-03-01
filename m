Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 6F1126B00E9
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 04:17:37 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 38D1E3EE0AE
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 18:17:35 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 200E345DD78
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 18:17:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0959B45DD74
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 18:17:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F1B731DB803C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 18:17:34 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AA63F1DB802C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 18:17:34 +0900 (JST)
Date: Thu, 1 Mar 2012 18:16:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH next] memcg: remove PCG_CACHE page_cgroup flag fix2
Message-Id: <20120301181600.26087800.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1202291841110.14002@eggly.anvils>
References: <alpine.LSU.2.00.1202282121160.4875@eggly.anvils>
	<alpine.LSU.2.00.1202282128500.4875@eggly.anvils>
	<20120229194304.GF1673@cmpxchg.org>
	<alpine.LSU.2.00.1202291718450.11821@eggly.anvils>
	<alpine.LSU.2.00.1202291841110.14002@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 29 Feb 2012 18:42:57 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Add comment to MEM_CGROUP_CHARGE_TYPE_MAPPED case in
> __mem_cgroup_uncharge_common().
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
> This one incremental to patch already in mm-commits.
> 
>  mm/memcontrol.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> --- mm-commits/mm/memcontrol.c	2012-02-28 20:45:43.488100423 -0800
> +++ linux/mm/memcontrol.c	2012-02-29 18:21:49.144702180 -0800
> @@ -2953,6 +2953,11 @@ __mem_cgroup_uncharge_common(struct page
>  
>  	switch (ctype) {
>  	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
> +		/*
> +		 * Generally PageAnon tells if it's the anon statistics to be
> +		 * updated; but sometimes e.g. mem_cgroup_uncharge_page() is
> +		 * used before page reached the stage of being marked PageAnon.
> +		 */
>  		anon = true;
>  		/* fallthrough */
>  	case MEM_CGROUP_CHARGE_TYPE_DROP:
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
