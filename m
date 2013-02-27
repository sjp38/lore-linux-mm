Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 75C306B0005
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 10:52:05 -0500 (EST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 27 Feb 2013 08:52:04 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id EA37C19D8048
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 08:51:56 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1RFptZr287472
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 08:51:56 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1RFprpU031039
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 08:51:53 -0700
Message-ID: <512E2B91.6000506@linux.vnet.ibm.com>
Date: Wed, 27 Feb 2013 07:51:45 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, show_mem: suppress page counts in non-blockable contexts
References: <alpine.DEB.2.02.1302261642520.11109@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1302261642520.11109@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/26/2013 04:46 PM, David Rientjes wrote:
> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> --- a/arch/arm/mm/init.c
> +++ b/arch/arm/mm/init.c
> @@ -99,6 +99,9 @@ void show_mem(unsigned int filter)
>  	printk("Mem-info:\n");
>  	show_free_areas(filter);
> 
> +	if (filter & SHOW_MEM_FILTER_PAGE_COUNT)
> +		return;
> +

Won't this just look like a funky truncated warning to the end user?

Seems like we should at least dump out a little message for this stuff
to say that it's intentionally truncated?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
