Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A2CDE6B01E3
	for <linux-mm@kvack.org>; Sun, 16 May 2010 20:00:43 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4H00euc018088
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 17 May 2010 09:00:40 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F37F045DE61
	for <linux-mm@kvack.org>; Mon, 17 May 2010 09:00:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 99CC245DE57
	for <linux-mm@kvack.org>; Mon, 17 May 2010 09:00:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 42351E0801B
	for <linux-mm@kvack.org>; Mon, 17 May 2010 09:00:39 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 09EB7E08016
	for <linux-mm@kvack.org>; Mon, 17 May 2010 09:00:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2] mm: Consider the entire user address space during node migration
In-Reply-To: <1273962913-8950-1-git-send-email-gthelen@google.com>
References: <AANLkTil4zgqBtBAp--P8VdynpbohxVosQ-qFiQQ_c5Bb@mail.gmail.com> <1273962913-8950-1-git-send-email-gthelen@google.com>
Message-Id: <20100517085953.21A2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 17 May 2010 09:00:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Changes since v1:
> - Use mm->task_size rather than TASK_SIZE_MAX to support all platforms.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Looks good. Thanks Greg!
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


> ---
>  mm/mempolicy.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 9f11728..2fd17e7 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -928,7 +928,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
>  	nodes_clear(nmask);
>  	node_set(source, nmask);
>  
> -	check_range(mm, mm->mmap->vm_start, TASK_SIZE, &nmask,
> +	check_range(mm, mm->mmap->vm_start, mm->task_size, &nmask,
>  			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
>  
>  	if (!list_empty(&pagelist))
> -- 
> 1.7.0.1
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
