Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 111A16B01F0
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 00:35:24 -0400 (EDT)
Date: Tue, 31 Aug 2010 13:33:29 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 5/5] memcg: generic file stat accounting interface
Message-Id: <20100831133329.3c54b214.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100825171140.69c1661a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100825170435.15f8eb73.kamezawa.hiroyu@jp.fujitsu.com>
	<20100825171140.69c1661a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Aug 2010 17:11:40 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Preparing for adding new status arounf file caches.(dirty, writeback,etc..)
> Using a unified macro and more generic names.
> All counters will have the same rule for updating.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

one nitpick.

> @@ -2042,17 +2031,20 @@ static void __mem_cgroup_commit_charge(s
>  static void __mem_cgroup_move_account(struct page_cgroup *pc,
>  	struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
>  {
> +	int i;
>  	VM_BUG_ON(from == to);
>  	VM_BUG_ON(PageLRU(pc->page));
>  	VM_BUG_ON(!PageCgroupLocked(pc));
>  	VM_BUG_ON(!PageCgroupUsed(pc));
>  	VM_BUG_ON(id_to_memcg(pc->mem_cgroup, true) != from);
>  
> -	if (PageCgroupFileMapped(pc)) {
> +	for (i = MEM_CGROUP_FSTAT_BASE; i < MEM_CGROUP_FSTAT_END; ++i) {
> +		if (!test_bit(fflag_idx(MEMCG_FSTAT_IDX(i)), &pc->flags))
> +			continue;
>  		/* Update mapped_file data for mem_cgroup */
It might be better to update this comment too.

	/* Update file-stat data for mem_cgroup */

or something ?

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
