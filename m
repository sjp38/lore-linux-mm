Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4PKfN6n002661
	for <linux-mm@kvack.org>; Wed, 25 May 2005 16:41:23 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4PKfK5Z144348
	for <linux-mm@kvack.org>; Wed, 25 May 2005 16:41:23 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4PKfFu0025026
	for <linux-mm@kvack.org>; Wed, 25 May 2005 16:41:15 -0400
Date: Wed, 25 May 2005 13:40:56 -0700
From: Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: Avoiding external fragmentation with a placement policy Version 11
Message-ID: <20050525204056.GA9257@w-mikek2.ibm.com>
References: <20050522200507.6ED7AECFC@skynet.csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050522200507.6ED7AECFC@skynet.csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Sun, May 22, 2005 at 09:05:07PM +0100, Mel Gorman wrote:
>  /*
> + * Calculate the size of the zone->usemap
> + */
> +static unsigned long __init usemap_size(unsigned long zonesize) {
> +	unsigned long usemapsize;
> +
> +	/* - Number of MAX_ORDER blocks in the zone */
> +	usemapsize = (zonesize + (1 << (MAX_ORDER-1))) >> (MAX_ORDER-1);
> +
> +	/* - BITS_PER_ALLOC_TYPE bits to record what type of block it is */
> +	usemapsize = (usemapsize * BITS_PER_ALLOC_TYPE + (sizeof(unsigned long)*8)) / 8;
> +
> +	return L1_CACHE_ALIGN(usemapsize);
> +}

In the first calculation, I think you are trying to 'round up'.  If this
is the case, then I believe the calculation should be:

usemapsize = (zonesize + ((1 << (MAX_ORDER-1)) - 1) >> (MAX_ORDER-1);

I don't know if there is a similar issue in the second calculation.
Arithmetic is not one of my strengths.

-- 
Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
