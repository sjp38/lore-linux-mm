Subject: Re: [PATCH][for -mm] per-zone and reclaim enhancements for memory
 controller take 3 [3/10] per-zone active inactive counter
In-Reply-To: Your message of "Tue, 27 Nov 2007 12:00:48 +0900"
	<20071127120048.ef5f2005.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071127120048.ef5f2005.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20071129033328.20E5F1CFEAA@siro.lan>
Date: Thu, 29 Nov 2007 12:33:28 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, akpm@linux-foundation.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

> +static inline struct mem_cgroup_per_zone *
> +mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
> +{
> +	if (!mem->info.nodeinfo[nid])

can this be true?

YAMAMOTO Takashi

> +		return NULL;
> +	return &mem->info.nodeinfo[nid]->zoneinfo[zid];
> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
