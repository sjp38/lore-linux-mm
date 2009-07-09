Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8F4BB6B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 05:58:23 -0400 (EDT)
Received: by yxe38 with SMTP id 38so57217yxe.12
        for <linux-mm@kvack.org>; Thu, 09 Jul 2009 03:14:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090709170535.23BA.A69D9226@jp.fujitsu.com>
References: <20090709165820.23B7.A69D9226@jp.fujitsu.com>
	 <20090709170535.23BA.A69D9226@jp.fujitsu.com>
Date: Thu, 9 Jul 2009 19:14:04 +0900
Message-ID: <28c262360907090314p466722eeq93384561ab725e94@mail.gmail.com>
Subject: Re: [PATCH 1/5][resend] add per-zone statistics to show_free_areas()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 9, 2009 at 5:06 PM, KOSAKI
Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
> Subject: [PATCH] add per-zone statistics to show_free_areas()
>
> show_free_areas() displays only a limited amount of zone counters. This
> patch includes additional counters in the display to allow easier
> debugging. This may be especially useful if an OOM is due to running out
> of DMA memory.
>
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> Acked-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
