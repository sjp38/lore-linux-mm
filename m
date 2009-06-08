Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 526BA6B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 09:36:53 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 01A7C82C43C
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 11:11:30 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id u9KSEtkE63OS for <linux-mm@kvack.org>;
	Mon,  8 Jun 2009 11:11:29 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9B1D482C43F
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 11:11:23 -0400 (EDT)
Date: Mon, 8 Jun 2009 10:55:55 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/3] Reintroduce zone_reclaim_interval for when zone_reclaim()
 scans and fails to avoid CPU spinning at 100% on NUMA
In-Reply-To: <20090608143857.GG15070@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0906081055170.21954@gentwo.org>
References: <1244466090-10711-1-git-send-email-mel@csn.ul.ie> <1244466090-10711-2-git-send-email-mel@csn.ul.ie> <4A2D129D.3020309@redhat.com> <20090608135433.GD15070@csn.ul.ie> <alpine.DEB.1.10.0906081033060.21954@gentwo.org>
 <20090608143857.GG15070@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 8 Jun 2009, Mel Gorman wrote:

> > The tmpfs pages are unreclaimable and therefore should not be on the anon
> > lru.
> >
>
> tmpfs pages can be swap-backed so can be reclaimable. Regardless of what
> list they are on, we still need to know how many of them there are if
> this patch is to be avoided.

If they are reclaimable then why does it matter? They can be pushed out if
you configure zone reclaim to be that aggressive.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
