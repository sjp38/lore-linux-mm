Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 052C46B0047
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 09:48:55 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id o94DmoAP024213
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 00:48:50 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o94Dmop32228234
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 00:48:51 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o94Dmox5017751
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 00:48:50 +1100
Message-ID: <4CA9DB3E.6020106@linux.vnet.ibm.com>
Date: Mon, 04 Oct 2010 19:18:46 +0530
From: Ciju Rajan K <ciju@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/10] memcg: create extensible page stat update routines
References: <1286175485-30643-1-git-send-email-gthelen@google.com> <1286175485-30643-4-git-send-email-gthelen@google.com>
In-Reply-To: <1286175485-30643-4-git-send-email-gthelen@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ciju Rajan K <ciju@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Greg Thelen wrote:
> Replace usage of the mem_cgroup_update_file_mapped() memcg
> statistic update routine with two new routines:
> * mem_cgroup_inc_page_stat()
> * mem_cgroup_dec_page_stat()
>
> As before, only the file_mapped statistic is managed.  However,
> these more general interfaces allow for new statistics to be
> more easily added.  New statistics are added with memcg dirty
> page accounting.
>
>
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 512cb12..f4259f4 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1592,7 +1592,9 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
>   * possibility of race condition. If there is, we take a lock.
>   */
>
>   
> -static void mem_cgroup_update_file_stat(struct page *page, int idx, int val)
>   
Not seeing this function in mmotm 28/09. So not able to apply this patch.
Am I missing anything?
> +void mem_cgroup_update_page_stat(struct page *page,
> +				 enum mem_cgroup_write_page_stat_item idx,
> +				 int val)
>  {
>  	struct mem_cgroup *mem;
>
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
