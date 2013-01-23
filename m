Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id A59946B0010
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 19:01:49 -0500 (EST)
Date: Wed, 23 Jan 2013 01:01:47 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] MAX_PAUSE to be at least 4
Message-ID: <20130123000147.GC7497@quack.suse.cz>
References: <201301210307.r0L37YuG018834@como.maths.usyd.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201301210307.r0L37YuG018834@como.maths.usyd.edu.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: linux-mm@kvack.org, 695182@bugs.debian.org, linux-kernel@vger.kernel.org

On Mon 21-01-13 14:07:34, paul.szabo@sydney.edu.au wrote:
> Ensure MAX_PAUSE is 4 or larger, so limits in
> 	return clamp_val(t, 4, MAX_PAUSE);
> (the only use of it) are not back-to-front.
> 
> (This patch does not solve the PAE OOM issue.)
> 
> Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
> School of Mathematics and Statistics   University of Sydney    Australia
  I guess this isn't needed in patch changelog?

  Also clamp_val(t, 4, MAX_PAUSE) doesn't seem to exist anymore?

								Honza
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
