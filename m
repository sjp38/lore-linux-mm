Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 630FF8D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 00:00:37 -0500 (EST)
Received: by iyi20 with SMTP id 20so4356621iyi.14
        for <linux-mm@kvack.org>; Sun, 06 Feb 2011 21:00:34 -0800 (PST)
Subject: Re: [PATCH] memblock: Fix error path in memblock_add_region()
From: Namhyung Kim <namhyung@gmail.com>
In-Reply-To: <4D4EDE69.9060200@kernel.org>
References: <1296999075-8022-1-git-send-email-namhyung@gmail.com>
	 <4D4EDE69.9060200@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 07 Feb 2011 14:00:27 +0900
Message-ID: <1297054827.1444.2.camel@leonhard>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>

2011-02-06 (i? 1/4 ), 09:46 -0800, Yinghai Lu:
> we can skip the restoring.
> 
> Thanks
> 
> Yinghai
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index bdba245..3231657 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -374,13 +374,9 @@ static long __init_memblock memblock_add_region(struct memblock_type *type, phys
>  	}
>  	type->cnt++;
>  
> -	/* The array is full ? Try to resize it. If that fails, we undo
> -	 * our allocation and return an error
> -	 */
> -	if (type->cnt == type->max && memblock_double_array(type)) {
> -		type->cnt--;
> +	/* The array is full ? Try to resize it  */
> +	if (type->cnt == type->max && memblock_double_array(type))
>  		return -1;
> -	}
>  
>  	return 0;
>  }

Looks OK to me, too.
Thanks.


-- 
Regards,
Namhyung Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
