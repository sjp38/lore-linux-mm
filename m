Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAHEEL3x021677
	for <linux-mm@kvack.org>; Thu, 17 Nov 2005 09:14:21 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAHEELLZ124060
	for <linux-mm@kvack.org>; Thu, 17 Nov 2005 09:14:21 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jAHEEL3o024142
	for <linux-mm@kvack.org>; Thu, 17 Nov 2005 09:14:21 -0500
Subject: Re: [PATCH] mm: populated_zone
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <200511180101.43084.kernel@kolivas.org>
References: <200511180101.43084.kernel@kolivas.org>
Content-Type: text/plain
Date: Thu, 17 Nov 2005 15:14:14 +0100
Message-Id: <1132236854.5834.67.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-11-18 at 01:01 +1100, Con Kolivas wrote:
> +static inline int populated_zone(struct zone *zone)
> +{
> +	return (!!zone->present_pages);
> +}

I really like when people do (zone->present_pages != 0) instead.  I
always do a double-take at the !! stuff.  Hard to understand at a
glance.

A good patch otherwise.  I had to go change a bunch of reference to
present_pages to spanned_pages when testing memory hotplug, and this
would make doing that much easier.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
