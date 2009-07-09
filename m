Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C7FE46B005C
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 10:43:18 -0400 (EDT)
Message-ID: <4A560605.50006@redhat.com>
Date: Thu, 09 Jul 2009 11:00:21 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] add buffer cache information to show_free_areas()
References: <20090709165820.23B7.A69D9226@jp.fujitsu.com> <20090709171027.23C0.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090709171027.23C0.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> ChangeLog
>   Since v2
>    - Changed display order, now, "buffer" field display right after unstable
> 
>   Since v1
>    - Fixed showing the number with kilobyte unit issue
> 
> ================
> Subject: [PATCH] add buffer cache information to show_free_areas()
> 
> When administrator analysis memory shortage reason from OOM log, They
> often need to know rest number of cache like pages.
> 
> Then, show_free_areas() shouldn't only display page cache, but also it
> should display buffer cache.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Wu Fengguang <fengguang.wu@intel.com>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
