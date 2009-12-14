Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E3C2F6B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 09:47:11 -0500 (EST)
Message-ID: <4B264FE9.4060901@redhat.com>
Date: Mon, 14 Dec 2009 09:47:05 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] Use TASK_KILLABLE instead TASK_UNINTERRUPTIBLE
References: <20091211164651.036f5340@annuminas.surriel.com> <20091214210823.BBAE.A69D9226@jp.fujitsu.com> <20091214213145.BBC3.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091214213145.BBC3.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On 12/14/2009 07:32 AM, KOSAKI Motohiro wrote:
> When fork bomb invoke OOM Killer, almost task might start to reclaim and
> sleep on shrink_zone_begin(). if we use TASK_UNINTERRUPTIBLE, OOM killer
> can't kill such task. it mean we never recover from fork bomb.
>
> This patch fixes it.
>
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

As with patch 4/8 I am not convinced that wake_up_all is
the correct thing to do.

Other than that:

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
