Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id BDFDD6B0010
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 19:04:37 -0500 (EST)
Date: Tue, 22 Jan 2013 16:04:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] MAX_PAUSE to be at least 4
Message-Id: <20130122160436.f0fa8352.akpm@linux-foundation.org>
In-Reply-To: <201301210307.r0L37YuG018834@como.maths.usyd.edu.au>
References: <201301210307.r0L37YuG018834@como.maths.usyd.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: linux-mm@kvack.org, 695182@bugs.debian.org, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>

On Mon, 21 Jan 2013 14:07:34 +1100
paul.szabo@sydney.edu.au wrote:

> Ensure MAX_PAUSE is 4 or larger, so limits in
> 	return clamp_val(t, 4, MAX_PAUSE);
> (the only use of it) are not back-to-front.

MAX_PAUSE is not used in this fashion in current kernels.

> (This patch does not solve the PAE OOM issue.)
> 
> Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
> School of Mathematics and Statistics   University of Sydney    Australia
> 
> Reported-by: Paul Szabo <psz@maths.usyd.edu.au>
> Reference: http://bugs.debian.org/695182
> Signed-off-by: Paul Szabo <psz@maths.usyd.edu.au>
> 
> --- mm/page-writeback.c.old	2012-12-06 22:20:40.000000000 +1100
> +++ mm/page-writeback.c	2013-01-21 13:57:05.000000000 +1100
> @@ -39,7 +39,7 @@
>  /*
>   * Sleep at most 200ms at a time in balance_dirty_pages().
>   */
> -#define MAX_PAUSE		max(HZ/5, 1)
> +#define MAX_PAUSE		max(HZ/5, 4)
>  
>  /*
>   * Estimate write bandwidth at 200ms intervals.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
