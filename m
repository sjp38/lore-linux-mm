Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CEF418D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 10:17:46 -0500 (EST)
Date: Mon, 28 Feb 2011 16:17:36 +0100
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 5/6] mm: add some KERN_CONT markers to continuation
 lines
Message-ID: <20110228151736.GO22310@pengutronix.de>
References: <20101124085645.GW4693@pengutronix.de>
 <1290589070-854-5-git-send-email-u.kleine-koenig@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1290589070-854-5-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, kernel@pengutronix.de, Arjan van de Ven <arjan@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

Hello,


On Wed, Nov 24, 2010 at 09:57:49AM +0100, Uwe Kleine-Konig wrote:
> Cc: linux-mm@kvack.org
> Signed-off-by: Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>
> ---
>  mm/percpu.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index efe8168..3356646 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -1117,20 +1117,20 @@ static void pcpu_dump_alloc_info(const char *lvl,
>  		for (alloc_end += gi->nr_units / upa;
>  		     alloc < alloc_end; alloc++) {
>  			if (!(alloc % apl)) {
> -				printk("\n");
> -				printk("%spcpu-alloc: ", lvl);
> +				printk(KERN_CONT "\n");
> +				printk("%spcpu-alloc:", lvl);
>  			}
> -			printk("[%0*d] ", group_width, group);
> +			printk(KERN_CONT " [%0*d]", group_width, group);
>  
>  			for (unit_end += upa; unit < unit_end; unit++)
>  				if (gi->cpu_map[unit] != NR_CPUS)
> -					printk("%0*d ", cpu_width,
> +					printk(KERN_CONT " %0*d", cpu_width,
>  					       gi->cpu_map[unit]);
>  				else
> -					printk("%s ", empty_str);
> +					printk(KERN_CONT " %s", empty_str);
>  		}
>  	}
> -	printk("\n");
> +	printk(KERN_CONT "\n");
>  }
>  
>  /**
ping

Best regards
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-Konig            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
