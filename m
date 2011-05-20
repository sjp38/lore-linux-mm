Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7C109900114
	for <linux-mm@kvack.org>; Fri, 20 May 2011 17:49:33 -0400 (EDT)
Date: Fri, 20 May 2011 14:49:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/8] memcg: easy check routine for reclaimable
Message-Id: <20110520144919.57541b8d.akpm@linux-foundation.org>
In-Reply-To: <20110520124212.facdc595.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520124212.facdc595.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>

On Fri, 20 May 2011 12:42:12 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> +bool mem_cgroup_test_reclaimable(struct mem_cgroup *memcg)
> +{
> +	unsigned long nr;
> +	int zid;
> +
> +	for (zid = NODE_DATA(0)->nr_zones - 1; zid >= 0; zid--)
> +		if (mem_cgroup_zone_reclaimable_pages(memcg, 0, zid))
> +			break;
> +	if (zid < 0)
> +		return false;
> +	return true;
> +}

A wee bit of documentation would be nice.  Perhaps improving the name
would suffice: mem_cgroup_has_reclaimable().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
