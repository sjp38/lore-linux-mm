Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF41600762
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 07:44:51 -0500 (EST)
Date: Wed, 2 Dec 2009 13:44:46 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 22/24] HWPOISON: add memory cgroup filter
Message-ID: <20091202124446.GA18989@one.firstfloor.org>
References: <20091202031231.735876003@intel.com> <20091202043046.519053333@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091202043046.519053333@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

>  
> +static int hwpoison_filter_task(struct page *p)
> +{

Can we make that ifdef instead of depends on ?

-Andi
>  config HWPOISON_INJECT
> -	tristate "Poison pages injector"
> +	tristate "HWPoison pages injector"
>  	depends on MEMORY_FAILURE && DEBUG_KERNEL
> +	depends on CGROUP_MEM_RES_CTLR_SWAP

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
