Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 880DA6B0083
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 22:10:24 -0400 (EDT)
Message-ID: <4A5E8C09.1030406@redhat.com>
Date: Wed, 15 Jul 2009 22:10:17 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: shrink_inactive_lis() nr_scan accounting fix
 fix
References: <20090716094619.9D07.A69D9226@jp.fujitsu.com> <20090716095241.9D0D.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090716095241.9D0D.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Subject: [PATCH] mm: shrink_inactive_lis() nr_scan accounting fix fix
> 
> If sc->isolate_pages() return 0, we don't need to call shrink_page_list().
> In past days, shrink_inactive_list() handled it properly.
> 
> But commit fb8d14e1 (three years ago commit!) breaked it. current shrink_inactive_list()
> always call shrink_page_list() although isolate_pages() return 0.
> 
> This patch restore proper return value check.
> 
> 
> Requirements:
>   o "nr_taken == 0" condition should stay before calling shrink_page_list().
>   o "nr_taken == 0" condition should stay after nr_scan related statistics
>      modification.
> 
> 
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
