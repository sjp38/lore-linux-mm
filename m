Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BB87A6B004F
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 09:15:17 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7348582C4DB
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 10:49:12 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id OBHnrYtF9sRQ for <linux-mm@kvack.org>;
	Mon,  8 Jun 2009 10:49:12 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2BB0A82C4E9
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 10:49:03 -0400 (EDT)
Date: Mon, 8 Jun 2009 10:33:41 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/3] Reintroduce zone_reclaim_interval for when zone_reclaim()
 scans and fails to avoid CPU spinning at 100% on NUMA
In-Reply-To: <20090608135433.GD15070@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0906081033060.21954@gentwo.org>
References: <1244466090-10711-1-git-send-email-mel@csn.ul.ie> <1244466090-10711-2-git-send-email-mel@csn.ul.ie> <4A2D129D.3020309@redhat.com> <20090608135433.GD15070@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 8 Jun 2009, Mel Gorman wrote:

> Yes, they're on separate LRU lists but they are not the only pages on those
> lists. The tmpfs pages are mixed in together with anonymous pages so we
> cannot use NR_*_ANON.

The tmpfs pages are unreclaimable and therefore should not be on the anon
lru.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
