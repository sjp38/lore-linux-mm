Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 016AE6B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 09:45:20 -0500 (EST)
Message-ID: <4B264F77.6040603@redhat.com>
Date: Mon, 14 Dec 2009 09:45:11 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/8] Stop reclaim quickly when the task reclaimed enough
 lots pages
References: <20091211164651.036f5340@annuminas.surriel.com> <20091214210823.BBAE.A69D9226@jp.fujitsu.com> <20091214213103.BBC0.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091214213103.BBC0.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On 12/14/2009 07:31 AM, KOSAKI Motohiro wrote:
>
>  From latency view, There isn't any reason shrink_zones() continue to
> reclaim another zone's page if the task reclaimed enough lots pages.

IIRC there is one reason - keeping equal pageout pressure
between zones.

However, it may be enough if just kswapd keeps evening out
the pressure, now that we limit the number of concurrent
direct reclaimers in the system.

Since kswapd does not use shrink_zones ...

> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
