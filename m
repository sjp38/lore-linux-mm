Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1E32E6B0055
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 05:40:05 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5G9fIhA029372
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Jun 2009 18:41:18 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E73745DE52
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 18:41:18 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E3A0145DE56
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 18:41:17 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C05CE1DB8040
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 18:41:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A4461DB8044
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 18:41:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm: Fix documentation of min_unmapped_ratio
In-Reply-To: <1245064482-19245-3-git-send-email-mel@csn.ul.ie>
References: <1245064482-19245-1-git-send-email-mel@csn.ul.ie> <1245064482-19245-3-git-send-email-mel@csn.ul.ie>
Message-Id: <20090616184100.99AC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 16 Jun 2009 18:41:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> -A percentage of the total pages in each zone.  Zone reclaim will only
> -occur if more than this percentage of pages are file backed and unmapped.
> -This is to insure that a minimal amount of local pages is still available for
> -file I/O even if the node is overallocated.
> +This is a percentage of the total pages in each zone. Zone reclaim will
> +only occur if more than this percentage of pages are in a state that
> +zone_reclaim_mode allows to be reclaimed.
> +
> +If zone_reclaim_mode has the value 4 OR'd, then the percentage is compared
> +against all file-backed unmapped pages including swapcache pages and tmpfs
> +files. Otherwise, only unmapped pages backed by normal files but not tmpfs
> +files and similar are considered.
>  
>  The default is 1 percent.

looks good.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
