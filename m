Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id E0EF36B0031
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 02:12:25 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3ED353EE0BD
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 15:12:24 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2992745DE5A
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 15:12:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 11D4245DE54
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 15:12:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F267F1DB8050
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 15:12:23 +0900 (JST)
Received: from g01jpfmpwkw02.exch.g01.fujitsu.local (g01jpfmpwkw02.exch.g01.fujitsu.local [10.0.193.56])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A78041DB804D
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 15:12:23 +0900 (JST)
Message-ID: <522D66AE.4060702@jp.fujitsu.com>
Date: Mon, 9 Sep 2013 15:11:58 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/cleanup: use pfn_to_nid() instead of page_to_nid(pfn_to_page())
References: <522D403C.3040801@huawei.com>
In-Reply-To: <522D403C.3040801@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, kosaki.motohiro@gmail.com

[CCing Kosaki since he maintains mm/memory_hotplug.c]

(2013/09/09 12:27), Xishi Qiu wrote:
> Use "pfn_to_nid(pfn)" instead of "page_to_nid(pfn_to_page(pfn))".
>

> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---

Acked-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

>   mm/memory_hotplug.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 85f80b7..a95dd28 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -937,7 +937,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>   	arg.nr_pages = nr_pages;
>   	node_states_check_changes_online(nr_pages, zone, &arg);
>
> -	nid = page_to_nid(pfn_to_page(pfn));
> +	nid = pfn_to_nid(pfn);
>
>   	ret = memory_notify(MEM_GOING_ONLINE, &arg);
>   	ret = notifier_to_errno(ret);
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
