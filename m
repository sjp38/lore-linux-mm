Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8A9F66B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 13:37:47 -0500 (EST)
Message-ID: <4AFDA724.7010200@redhat.com>
Date: Fri, 13 Nov 2009 13:36:20 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: Stop kswapd waiting on congestion when the min
 watermark is not being met
References: <20091113142608.33B9.A69D9226@jp.fujitsu.com> <20091113135443.GF29804@csn.ul.ie> <20091114023138.3DA5.A69D9226@jp.fujitsu.com> <20091113181557.GM29804@csn.ul.ie>
In-Reply-To: <20091113181557.GM29804@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 11/13/2009 01:15 PM, Mel Gorman wrote:
> If reclaim fails to make sufficient progress, the priority is raised.
> Once the priority is higher, kswapd starts waiting on congestion.  However,
> if the zone is below the min watermark then kswapd needs to continue working
> without delay as there is a danger of an increased rate of GFP_ATOMIC
> allocation failure.
>
> This patch changes the conditions under which kswapd waits on
> congestion by only going to sleep if the min watermarks are being met.
>
>
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 90b11e4..bc09547 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -685,6 +685,7 @@ static const char * const vmstat_text[] = {
>   	"kswapd_inodesteal",
>   	"kswapd_slept_prematurely_fast",
>   	"kswapd_slept_prematurely_slow",
> +	"kswapd_no_congestion_wait",
>   	
>    
Perhaps better named "kswapd_skip_congestion_wait" ?

Other than that, the patch looks good to me.

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
