Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5E1736B004A
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 11:23:38 -0400 (EDT)
Date: Fri, 22 Oct 2010 10:23:34 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: zone state overhead
In-Reply-To: <20101022141223.GF2160@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1010221015001.20437@router.home>
References: <20101014120804.8B8F.A69D9226@jp.fujitsu.com> <20101018103941.GX30667@csn.ul.ie> <20101019100658.A1B3.A69D9226@jp.fujitsu.com> <20101019090803.GF30667@csn.ul.ie> <20101022141223.GF2160@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Oct 2010, Mel Gorman wrote:

> index eaaea37..c67d333 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -254,6 +254,8 @@ extern void dec_zone_state(struct zone *, enum zone_stat_item);
>  extern void __dec_zone_state(struct zone *, enum zone_stat_item);
>
>  void refresh_cpu_vm_stats(int);
> +void disable_pgdat_percpu_threshold(pg_data_t *pgdat);
> +void enable_pgdat_percpu_threshold(pg_data_t *pgdat);
>  #else /* CONFIG_SMP */

The naming is a bit misleading since disabling may only mean reducing the
treshold.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
