Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 16DE36B004F
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 14:16:47 -0500 (EST)
Date: Wed, 7 Dec 2011 20:16:37 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: mark some messages as INFO
Message-ID: <20111207191637.GB12679@cmpxchg.org>
References: <1323277360-3155-1-git-send-email-teg@jklm.no>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1323277360-3155-1-git-send-email-teg@jklm.no>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Gundersen <teg@jklm.no>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 07, 2011 at 06:02:40PM +0100, Tom Gundersen wrote:
> @@ -4913,31 +4913,31 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
>  	find_zone_movable_pfns_for_nodes(zone_movable_pfn);
>  
>  	/* Print out the zone ranges */
> -	printk("Zone PFN ranges:\n");
> +	printk(KERN_INFO "Zone PFN ranges:\n");
>  	for (i = 0; i < MAX_NR_ZONES; i++) {
>  		if (i == ZONE_MOVABLE)
>  			continue;
> -		printk("  %-8s ", zone_names[i]);
> +		printk(KERN_INFO "  %-8s ", zone_names[i]);
>  		if (arch_zone_lowest_possible_pfn[i] ==
>  				arch_zone_highest_possible_pfn[i])
> -			printk("empty\n");
> +			printk(KERN_INFO "empty\n");
>  		else
> -			printk("%0#10lx -> %0#10lx\n",
> +			printk(KERN_INFO "%0#10lx -> %0#10lx\n",
>  				arch_zone_lowest_possible_pfn[i],
>  				arch_zone_highest_possible_pfn[i]);
>  	}

Shouldn't continuation lines be KERN_CONT instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
