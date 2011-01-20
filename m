Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 22C776B0092
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 09:49:32 -0500 (EST)
Date: Thu, 20 Jan 2011 08:49:27 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [REPOST] [PATCH 1/3] Move zone_reclaim() outside of CONFIG_NUMA
 (v3)
In-Reply-To: <20110120123608.30481.63446.stgit@localhost6.localdomain6>
Message-ID: <alpine.DEB.2.00.1101200847350.10695@router.home>
References: <20110120123039.30481.81151.stgit@localhost6.localdomain6> <20110120123608.30481.63446.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 20 Jan 2011, Balbir Singh wrote:

> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -253,11 +253,11 @@ extern int vm_swappiness;
>  extern int remove_mapping(struct address_space *mapping, struct page *page);
>  extern long vm_total_pages;
>
> +extern int sysctl_min_unmapped_ratio;
> +extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
>  #ifdef CONFIG_NUMA
>  extern int zone_reclaim_mode;
> -extern int sysctl_min_unmapped_ratio;
>  extern int sysctl_min_slab_ratio;
> -extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
>  #else
>  #define zone_reclaim_mode 0

So the end result of this patch is that zone reclaim is compiled
into vmscan.o even on !NUMA configurations but since zone_reclaim_mode ==
0 noone can ever call that code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
