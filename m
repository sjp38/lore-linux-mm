Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id BA27C6B00B3
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 04:59:46 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 214383EE0BC
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:59:45 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BA8345DEB5
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:59:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E850245DEB2
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:59:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DA11E1DB803B
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:59:44 +0900 (JST)
Received: from g01jpexchkw04.g01.fujitsu.local (g01jpexchkw04.g01.fujitsu.local [10.0.194.43])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 970A81DB8038
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 18:59:44 +0900 (JST)
Message-ID: <50A4BCF9.7080401@jp.fujitsu.com>
Date: Thu, 15 Nov 2012 18:59:21 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PART4 Patch 0/2] memory-hotplug: allow online/offline memory
 to result movable node
References: <1351671334-10243-1-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1351671334-10243-1-git-send-email-wency@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

2012/10/31 17:15, Wen Congyang wrote:
> From: Lai Jiangshan <laijs@cn.fujitsu.com>
> 
> This patch is part4 of the following patchset:
>      https://lkml.org/lkml/2012/10/29/319
> 
> Part1 is here:
>      https://lkml.org/lkml/2012/10/31/30
> 
> Part2 is here:
>      http://marc.info/?l=linux-kernel&m=135166705909544&w=2
> 
> Part3 is here:
>      http://marc.info/?l=linux-kernel&m=135167050510527&w=2
> 
> You must apply part1-3 before applying this patchset.
> 
> we need a node which only contains movable memory. This feature is very
> important for node hotplug. If a node has normal/highmem, the memory
> may be used by the kernel and can't be offlined. If the node only contains
> movable memory, we can offline the memory and the node.
> 
> 
> Lai Jiangshan (2):
>    numa: add CONFIG_MOVABLE_NODE for movable-dedicated node
>    memory_hotplug: allow online/offline memory to result movable node
> 
>   drivers/base/node.c      |  6 ++++++
>   include/linux/nodemask.h |  4 ++++
>   mm/Kconfig               |  8 ++++++++
>   mm/memory_hotplug.c      | 16 ++++++++++++++++
>   mm/page_alloc.c          |  3 +++
>   5 files changed, 37 insertions(+)
> 

Tested-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
