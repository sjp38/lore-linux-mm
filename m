Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7C0566B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 13:25:16 -0400 (EDT)
Message-ID: <4A2EA5D9.6050602@redhat.com>
Date: Tue, 09 Jun 2009 14:11:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] Do not unconditionally treat zones that fail zone_reclaim()
 as full
References: <1244566904-31470-1-git-send-email-mel@csn.ul.ie> <1244566904-31470-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1244566904-31470-3-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:

> There is a side-effect to this patch. Currently, if zone_reclaim()
> successfully reclaimed SWAP_CLUSTER_MAX, an allocation attempt would
> go ahead. With this patch applied, zone watermarks are rechecked after
> zone_reclaim() does some work.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
