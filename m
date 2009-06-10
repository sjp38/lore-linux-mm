Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 211CC6B0055
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 21:46:00 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5A1lPFl016668
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 10 Jun 2009 10:47:25 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3746545DE52
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 10:47:25 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F5FB45DE4F
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 10:47:25 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E34C01DB803F
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 10:47:24 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 89551E08009
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 10:47:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] Count the number of times zone_reclaim() scans and fails
In-Reply-To: <1244566904-31470-4-git-send-email-mel@csn.ul.ie>
References: <1244566904-31470-1-git-send-email-mel@csn.ul.ie> <1244566904-31470-4-git-send-email-mel@csn.ul.ie>
Message-Id: <20090610104635.DDA6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 10 Jun 2009 10:47:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi

I like this patch. thank you mel.

> @@ -2489,6 +2489,10 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  	ret = __zone_reclaim(zone, gfp_mask, order);
>  	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
>  
> +	if (!ret) {
> +		count_vm_events(PGSCAN_ZONERECLAIM_FAILED, 1);
> +	}
> +
>  	return ret;


count_vm_event(PGSCAN_ZONERECLAIM_FAILED)?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
