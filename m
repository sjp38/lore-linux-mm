Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7697D6B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 18:57:59 -0500 (EST)
Received: by yxe10 with SMTP id 10so3339733yxe.12
        for <linux-mm@kvack.org>; Mon, 14 Dec 2009 15:57:57 -0800 (PST)
Date: Tue, 15 Dec 2009 08:52:26 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 7/8] Use TASK_KILLABLE instead TASK_UNINTERRUPTIBLE
Message-Id: <20091215085226.5f07b470.minchan.kim@barrios-desktop>
In-Reply-To: <20091214213145.BBC3.A69D9226@jp.fujitsu.com>
References: <20091211164651.036f5340@annuminas.surriel.com>
	<20091214210823.BBAE.A69D9226@jp.fujitsu.com>
	<20091214213145.BBC3.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 14 Dec 2009 21:32:18 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> When fork bomb invoke OOM Killer, almost task might start to reclaim and
> sleep on shrink_zone_begin(). if we use TASK_UNINTERRUPTIBLE, OOM killer
> can't kill such task. it mean we never recover from fork bomb.
> 
> This patch fixes it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

I doubt wake_up_all, too. I think it's typo.
Otherwise, Looks good to me. 

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
