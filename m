Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 4BD926B0034
	for <linux-mm@kvack.org>; Mon, 13 May 2013 05:40:37 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1368293689-16410-17-git-send-email-jiang.liu@huawei.com>
References: <1368293689-16410-17-git-send-email-jiang.liu@huawei.com> <1368293689-16410-1-git-send-email-jiang.liu@huawei.com>
Subject: Re: [PATCH v6, part3 16/16] AVR32: fix building warnings caused by redifinitions of HZ
Date: Mon, 13 May 2013 10:40:05 +0100
Message-ID: <15932.1368438005@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Haavard Skinnemoen <hskinnemoen@gmail.com>

Jiang Liu <liuj97@gmail.com> wrote:

> -#ifndef HZ
> +#ifndef __KERNEL__
> +   /*
> +    * Technically, this is wrong, but some old apps still refer to it.
> +    * The proper way to get the HZ value is via sysconf(_SC_CLK_TCK).
> +    */
>  # define HZ		100
>  #endif

Better still, use asm-generic/param.h and uapi/asm-generic/param.h for AVR32
instead.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
