Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D52336B005A
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 08:15:00 -0400 (EDT)
Message-ID: <4A2D129D.3020309@redhat.com>
Date: Mon, 08 Jun 2009 09:31:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] Reintroduce zone_reclaim_interval for when zone_reclaim()
 scans and fails to avoid CPU spinning at 100% on NUMA
References: <1244466090-10711-1-git-send-email-mel@csn.ul.ie> <1244466090-10711-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1244466090-10711-2-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:

> The scanning occurs because zone_reclaim() cannot tell
> in advance the scan is pointless because the counters do not distinguish
> between pagecache pages backed by disk and by RAM. 

Yes it can.  Since 2.6.27, filesystem backed and swap/ram backed
pages have been living on separate LRU lists.  This allows you to
fix the underlying problem, instead of having to add a retry
interval.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
