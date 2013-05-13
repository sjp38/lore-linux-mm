Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 0458F6B0039
	for <linux-mm@kvack.org>; Mon, 13 May 2013 05:19:29 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1368293689-16410-15-git-send-email-jiang.liu@huawei.com>
References: <1368293689-16410-15-git-send-email-jiang.liu@huawei.com> <1368293689-16410-1-git-send-email-jiang.liu@huawei.com>
Subject: Re: [PATCH v6, part3 14/16] mm: concentrate modification of totalram_pages into the mm core
Date: Mon, 13 May 2013 10:19:11 +0100
Message-ID: <15411.1368436751@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Jiang Liu <liuj97@gmail.com> wrote:

> Concentrate code to modify totalram_pages into the mm core, so the arch
> memory initialized code doesn't need to take care of it. With these
> changes applied, only following functions from mm core modify global
> variable totalram_pages:
> free_bootmem_late(), free_all_bootmem(), free_all_bootmem_node(),
> adjust_managed_page_count().
> 
> With this patch applied, it will be much more easier for us to keep
> totalram_pages and zone->managed_pages in consistence.

I like it.

Acked-by: David Howells <dhowells@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
