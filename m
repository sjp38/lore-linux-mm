Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B1EEE6B003D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 08:15:13 -0400 (EDT)
Message-ID: <4A002DD4.4080401@redhat.com>
Date: Tue, 05 May 2009 08:15:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: ZVC updates in shrink_active_list() can be done
 once
References: <20090504234455.GA6324@localhost>
In-Reply-To: <20090504234455.GA6324@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "a.p.zijlstra@chello.nl" <a.p.zijlstra@chello.nl>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "npiggin@suse.de" <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> This effectively lifts the unit of nr_inactive_* and pgdeactivate updates
> from PAGEVEC_SIZE=14 to SWAP_CLUSTER_MAX=32.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
