Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id A82106B0062
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 19:29:22 -0500 (EST)
Date: Thu, 15 Nov 2012 16:29:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PART3 Patch v2 13/14] page_alloc: use N_MEMORY instead
 N_HIGH_MEMORY change the node_states initialization
Message-Id: <20121115162920.af46d08a.akpm@linux-foundation.org>
In-Reply-To: <1352969857-26623-14-git-send-email-wency@cn.fujitsu.com>
References: <1352969857-26623-1-git-send-email-wency@cn.fujitsu.com>
	<1352969857-26623-14-git-send-email-wency@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Rob Landley <rob@landley.net>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>, Lin feng <linfeng@cn.fujitsu.com>

On Thu, 15 Nov 2012 16:57:36 +0800
Wen Congyang <wency@cn.fujitsu.com> wrote:

> N_HIGH_MEMORY stands for the nodes that has normal or high memory.
> N_MEMORY stands for the nodes that has any memory.
> 
> The code here need to handle with the nodes which have memory, we should
> use N_MEMORY instead.
> 
> Since we introduced N_MEMORY, we update the initialization of node_states.

reset_zone_present_pages() has been removed by the recently-queued
revert-mm-fix-up-zone-present-pages.patch, so I dropped that hunk.

We still have

akpm:/usr/src/25> grep N_HIGH_MEMORY mm/page_alloc.c
        [N_HIGH_MEMORY] = { { [0] = 1UL } },
                        node_set_state(nid, N_HIGH_MEMORY);
                        if (N_NORMAL_MEMORY != N_HIGH_MEMORY &&

which I hope is correct.  Can you please check it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
