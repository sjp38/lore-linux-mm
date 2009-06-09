Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 84C4D6B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 13:28:27 -0400 (EDT)
Message-ID: <4A2EA6A6.30003@redhat.com>
Date: Tue, 09 Jun 2009 14:15:02 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] Properly account for the number of page cache pages
 zone_reclaim() can reclaim
References: <1244566904-31470-1-git-send-email-mel@csn.ul.ie> <1244566904-31470-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1244566904-31470-2-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:

> This patch alters how zone_reclaim() works out how many pages it might be
> able to reclaim given the current reclaim_mode. If RECLAIM_SWAP is set
> in the reclaim_mode it will either consider NR_FILE_PAGES as potential
> candidates or else use NR_{IN}ACTIVE}_PAGES-NR_FILE_MAPPED to discount
> swapcache and other non-file-backed pages.  If RECLAIM_WRITE is not set,
> then NR_FILE_DIRTY number of pages are not candidates. If RECLAIM_SWAP is
> not set, then NR_FILE_MAPPED are not.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Christoph Lameter <cl@linux-foundation.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
