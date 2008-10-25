Received: from chimera.site ([71.117.247.66]) by xenotime.net for <linux-mm@kvack.org>; Sat, 25 Oct 2008 10:45:22 -0700
Date: Sat, 25 Oct 2008 10:45:11 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH]mm/oom_kill.c: cleanup kerneldoc of badness()
Message-Id: <20081025104511.374179b2.rdunlap@xenotime.net>
In-Reply-To: <200810260021.08146.qhfeng.kernel@gmail.com>
References: <200810260021.08146.qhfeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Qinghuang Feng <qhfeng.kernel@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 26 Oct 2008 00:21:08 +0800 Qinghuang Feng wrote:

> Paramter @mem has been removed since v2.6.26, now delete it's comment.
> 
> Signed-off-by: Qinghuang Feng <qhfeng.kernel@gmail.com>

Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Thanks.

> ---
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 64e5b4b..460f90e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -38,7 +38,6 @@ static DEFINE_SPINLOCK(zone_scan_mutex);
>   * badness - calculate a numeric value for how bad this task has been
>   * @p: task struct of which task we should calculate
>   * @uptime: current uptime in seconds
> - * @mem: target memory controller
>   *
>   * The formula used is relatively simple and documented inline in the
>   * function. The main rationale is that we want to select a good task

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
