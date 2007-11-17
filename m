Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAH9FmMb018187
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 04:15:48 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAH9FmXV100428
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 02:15:48 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAH9Fmkk018399
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 02:15:48 -0700
Message-ID: <473EB141.4000005@linux.vnet.ibm.com>
Date: Sat, 17 Nov 2007 14:45:45 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] memory controller per zone patches take 2 [2/10]
 add nid/zid function for page_cgroup
References: <20071116191107.46dd523a.kamezawa.hiroyu@jp.fujitsu.com> <20071116191635.2c141c38.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071116191635.2c141c38.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>  mm/memcontrol.c |   10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> Index: linux-2.6.24-rc2-mm1/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.24-rc2-mm1.orig/mm/memcontrol.c
> +++ linux-2.6.24-rc2-mm1/mm/memcontrol.c
> @@ -135,6 +135,16 @@ struct page_cgroup {
>  #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
>  #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
> 
> +static inline int page_cgroup_nid(struct page_cgroup *pc)
> +{
> +	return page_to_nid(pc->page);
> +}
> +
> +static inline int page_cgroup_zid(struct page_cgroup *pc)
> +{
> +	return page_zonenum(pc->page);

page_zonenum returns zone_type, isn't it better we carry the
type through to the caller?

> +}
> +
>  enum {
>  	MEM_CGROUP_TYPE_UNSPEC = 0,
>  	MEM_CGROUP_TYPE_MAPPED,
> 


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
