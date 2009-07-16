Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 53DB96B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 00:00:48 -0400 (EDT)
Received: by gxk3 with SMTP id 3so6941642gxk.14
        for <linux-mm@kvack.org>; Wed, 15 Jul 2009 21:00:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090716095119.9D0A.A69D9226@jp.fujitsu.com>
References: <20090716094619.9D07.A69D9226@jp.fujitsu.com>
	 <20090716095119.9D0A.A69D9226@jp.fujitsu.com>
Date: Thu, 16 Jul 2009 13:00:46 +0900
Message-ID: <28c262360907152100q4e570c18s19db0845411e352a@mail.gmail.com>
Subject: Re: [PATCH 1/3] Rename pgmoved variable in shrink_active_list()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Looks good to me.


On Thu, Jul 16, 2009 at 9:52 AM, KOSAKI
Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
> Subject: [PATCH] Rename pgmoved variable in shrink_active_list()
>
> Currently, pgmoved variable have two meanings. it cause harder reviewing a bit.
> This patch separate it.
>
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
