Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id DEC276B004F
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 16:41:41 -0500 (EST)
Received: by yenq10 with SMTP id q10so1141314yen.14
        for <linux-mm@kvack.org>; Wed, 07 Dec 2011 13:41:41 -0800 (PST)
Date: Wed, 7 Dec 2011 13:41:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: mark some messages as INFO
In-Reply-To: <20111207191637.GB12679@cmpxchg.org>
Message-ID: <alpine.DEB.2.00.1112071340420.27360@chino.kir.corp.google.com>
References: <1323277360-3155-1-git-send-email-teg@jklm.no> <20111207191637.GB12679@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tom Gundersen <teg@jklm.no>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 7 Dec 2011, Johannes Weiner wrote:

> > @@ -4913,31 +4913,31 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
> >  	find_zone_movable_pfns_for_nodes(zone_movable_pfn);
> >  
> >  	/* Print out the zone ranges */
> > -	printk("Zone PFN ranges:\n");
> > +	printk(KERN_INFO "Zone PFN ranges:\n");
> >  	for (i = 0; i < MAX_NR_ZONES; i++) {
> >  		if (i == ZONE_MOVABLE)
> >  			continue;
> > -		printk("  %-8s ", zone_names[i]);
> > +		printk(KERN_INFO "  %-8s ", zone_names[i]);
> >  		if (arch_zone_lowest_possible_pfn[i] ==
> >  				arch_zone_highest_possible_pfn[i])
> > -			printk("empty\n");
> > +			printk(KERN_INFO "empty\n");
> >  		else
> > -			printk("%0#10lx -> %0#10lx\n",
> > +			printk(KERN_INFO "%0#10lx -> %0#10lx\n",
> >  				arch_zone_lowest_possible_pfn[i],
> >  				arch_zone_highest_possible_pfn[i]);
> >  	}
> 
> Shouldn't continuation lines be KERN_CONT instead?
> 

Indeed, and I think it would benefit from using pr_info() and pr_cont() as 
well to avoid going over 80 characters per line.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
