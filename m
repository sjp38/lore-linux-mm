Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAHEFkRL009038
	for <linux-mm@kvack.org>; Thu, 17 Nov 2005 09:15:46 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAHEFkCc101710
	for <linux-mm@kvack.org>; Thu, 17 Nov 2005 09:15:46 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jAHEFjLw028556
	for <linux-mm@kvack.org>; Thu, 17 Nov 2005 09:15:46 -0500
Subject: Re: [PATCH] mm: is_dma_zone
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <200511180059.51211.kernel@kolivas.org>
References: <200511180059.51211.kernel@kolivas.org>
Content-Type: text/plain
Date: Thu, 17 Nov 2005 15:15:43 +0100
Message-Id: <1132236943.5834.70.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-11-18 at 00:59 +1100, Con Kolivas wrote:
> +static inline int is_dma(struct zone *zone)
> +{
> +       return zone == zone->zone_pgdat->node_zones + ZONE_DMA;
> +}

Any reason you can't just use 'zone_idx(z) == ZONE_DMA' here, just like
the code you replaced?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
