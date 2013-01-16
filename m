Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 5E21F6B0062
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 20:19:20 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 20:19:19 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id E15D26E8048
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 20:19:13 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G1JEZa339978
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 20:19:14 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G1JEu5004237
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 23:19:14 -0200
Message-ID: <50F6000A.3010601@linux.vnet.ibm.com>
Date: Tue, 15 Jan 2013 17:19:06 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/17] mmzone: add various zone_*() helper functions.
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com> <1358295894-24167-3-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-3-git-send-email-cody@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <jmesmon@gmail.com>

On 01/15/2013 04:24 PM, Cody P Schafer wrote:
> +static inline bool zone_spans_pfn(const struct zone *zone, unsigned long pfn)
> +{
> +	return zone->zone_start_pfn <= pfn && pfn < zone_end_pfn(zone);
> +}

This needs some parenthesis, just for readability.  There's also no
crime in breaking it up to be multi-line if you want.

> +static inline bool zone_is_initialized(struct zone *zone)
> +{
> +	return !!zone->wait_table;
> +}
> +
> +static inline bool zone_is_empty(struct zone *zone)
> +{
> +	return zone->spanned_pages == 0;
> +}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
