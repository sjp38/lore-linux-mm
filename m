Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 931908D0039
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 19:31:49 -0500 (EST)
Message-ID: <4D40BD00.1090408@bluewatersys.com>
Date: Thu, 27 Jan 2011 13:32:00 +1300
From: Ryan Mallon <ryan@bluewatersys.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] mm/page_alloc: use appropriate printk priority level
References: <20110125235700.GR8008@google.com> <1296084570-31453-2-git-send-email-msb@chromium.org>
In-Reply-To: <1296084570-31453-2-git-send-email-msb@chromium.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mandeep Singh Baines <msb@chromium.org>
Cc: gregkh@suse.de, rjw@sisk.pl, mingo@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/27/2011 12:29 PM, Mandeep Singh Baines wrote:
> printk()s without a priority level default to KERN_WARNING. To reduce
> noise at KERN_WARNING, this patch set the priority level appriopriately
> for unleveled printks()s. This should be useful to folks that look at
> dmesg warnings closely.
> 
> Signed-off-by: Mandeep Singh Baines <msb@chromium.org>
> ---

> @@ -4700,33 +4700,36 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
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
>  			printk("empty\n");

Should be printk(KERN_CONT ... (or pr_cont).

>  		else
> -			printk("%0#10lx -> %0#10lx\n",
> +			printk(KERN_INFO "%0#10lx -> %0#10lx\n",
>  				arch_zone_lowest_possible_pfn[i],
>  				arch_zone_highest_possible_pfn[i]);

The printk above doesn't have a trailing newline so this should be
printk(KERN_CONT ...

There are a couple of other places in this patch series that also need
to be fixed in a similar manner.

~Ryan

-- 
Bluewater Systems Ltd - ARM Technology Solution Centre

Ryan Mallon         		5 Amuri Park, 404 Barbadoes St
ryan@bluewatersys.com         	PO Box 13 889, Christchurch 8013
http://www.bluewatersys.com	New Zealand
Phone: +64 3 3779127		Freecall: Australia 1800 148 751
Fax:   +64 3 3779135			  USA 1800 261 2934

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
