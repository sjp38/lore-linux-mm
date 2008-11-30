Message-ID: <4932BA13.7000409@redhat.com>
Date: Sun, 30 Nov 2008 11:06:43 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/09] memcg: make zone_reclaim_stat
References: <20081130193502.8145.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081130195731.8151.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20081130195731.8151.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:

> +struct zone_reclaim_stat*
> +mem_cgroup_get_reclaim_stat_by_page(struct page *page)
> +{
> +	return NULL;
> +}

> +		memcg_reclaim_stat = mem_cgroup_get_reclaim_stat_by_page(page);
> +		memcg_reclaim_stat->recent_rotated[!!file]++;
> +		memcg_reclaim_stat->recent_scanned[!!file]++;

Won't this cause a null pointer dereference when
not using memcg?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
