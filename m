Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 29FB96B0078
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 19:17:55 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1C0HqM8014211
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Feb 2010 09:17:52 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9276445DE4F
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 09:17:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7117F45DE4E
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 09:17:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A8E21DB803B
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 09:17:52 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 15DD01DB8038
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 09:17:52 +0900 (JST)
Date: Fri, 12 Feb 2010 09:14:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] memcg: check if first threshold crossed
Message-Id: <20100212091429.d1115b17.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1265846123-2244-1-git-send-email-kirill@shutemov.name>
References: <1265846123-2244-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Thu, 11 Feb 2010 01:55:23 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> There is a bug in memory thresholds code. We don't check if first
> threshold (array index 0) was crossed down. This patch fixes it.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: Pavel Emelyanov <xemul@openvz.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 41e00c2..a443c30 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3252,7 +3252,7 @@ static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
>  	 * If none of thresholds below usage is crossed, we read
>  	 * only one element of the array here.
>  	 */
> -	for (; i > 0 && unlikely(t->entries[i].threshold > usage); i--)
> +	for (; i >= 0 && unlikely(t->entries[i].threshold > usage); i--)
>  		eventfd_signal(t->entries[i].eventfd, 1);
>  
>  	/* i = current_threshold + 1 */
> -- 
> 1.6.5.8
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
