Message-ID: <466C3219.4040406@redhat.com>
Date: Sun, 10 Jun 2007 13:17:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 14 of 16] oom select should only take rss into account
References: <dbd70ffd95f34cd12f1f.1181332992@v2.random>
In-Reply-To: <dbd70ffd95f34cd12f1f.1181332992@v2.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -66,7 +66,7 @@ unsigned long badness(struct task_struct
>  	/*
>  	 * The memory size of the process is the basis for the badness.
>  	 */
> -	points = mm->total_vm;
> +	points = get_mm_rss(mm);

Makes sense.  Originally it used total_vm so it could also
select tasks that use up lots of swap, but I guess that in
almost all the cases the preferred OOM task to kill is also
using a lot of RAM.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
