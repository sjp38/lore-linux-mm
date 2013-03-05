Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id D1F696B000A
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 11:52:39 -0500 (EST)
Date: Tue, 5 Mar 2013 17:50:02 +0100
From: Hans-Christian Egtvedt <egtvedt@samfundet.no>
Subject: Re: [RFC PATCH v1 04/33] mm/avr32: use common help functions to
 free reserved pages
Message-ID: <20130305165002.GA4621@samfundet.no>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
 <1362495317-32682-5-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1362495317-32682-5-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Haavard Skinnemoen <hskinnemoen@gmail.com>

Around Tue 05 Mar 2013 22:54:47 +0800 or thereabout, Jiang Liu wrote:
> Use common help functions to free reserved pages.
>

AFAICT it looks good, thanks for updating.

> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>

Acked-by: Hans-Christian Egtvedt <egtvedt@samfundet.no>

> Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
> Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
> ---
>  arch/avr32/mm/init.c |   24 ++----------------------
>  1 file changed, 2 insertions(+), 22 deletions(-)

<snipp diff>

-- 
Hans-Christian Egtvedt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
