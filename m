Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 77BEB6B004A
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 11:27:59 -0400 (EDT)
Date: Fri, 22 Oct 2010 10:27:55 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: zone state overhead
In-Reply-To: <20101022141223.GF2160@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1010221024080.20437@router.home>
References: <20101014120804.8B8F.A69D9226@jp.fujitsu.com> <20101018103941.GX30667@csn.ul.ie> <20101019100658.A1B3.A69D9226@jp.fujitsu.com> <20101019090803.GF30667@csn.ul.ie> <20101022141223.GF2160@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Oct 2010, Mel Gorman wrote:

>
> +void disable_pgdat_percpu_threshold(pg_data_t *pgdat)

Call this set_pgdat_stat_threshold() and make it take a calculate_pressure
() function?

void set_pgdat_stat_threshold(pg_data_t *pgdat, int (*calculate_pressure)(struct zone *)) ?

Then  do

	set_pgdat_stat_threshold(pgdat, threshold_normal)

	set_pgdat_stat_threshold(pgdat, threshold_pressure)

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
