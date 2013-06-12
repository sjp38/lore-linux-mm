Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 2FECE6B0036
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 17:50:43 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 12 Jun 2013 15:50:33 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id A23CD19D804A
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 15:50:22 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5CLoImw117660
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 15:50:18 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5CLoIm1003058
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 15:50:18 -0600
Message-ID: <51B8ED17.2060608@linux.vnet.ibm.com>
Date: Wed, 12 Jun 2013 14:50:15 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/page_alloc: don't re-init pageset in zone_pcp_update()
References: <1370988779-7586-1-git-send-email-cody@linux.vnet.ibm.com> <20130612142032.882a28b7911ed24ca19e282e@linux-foundation.org> <51B8EC10.6070304@linux.vnet.ibm.com>
In-Reply-To: <51B8EC10.6070304@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Valdis.Kletnieks@vt.edu

> Anyhow, a reorganized (and clearer) changelog with the same content
> follows:
> ---

I made a few wording tweaks:
---
mm/page_alloc: don't re-init pageset in zone_pcp_update()

When memory hotplug is triggered, we call pageset_init() on
per-cpu-pagesets which both contain pages and are in use, causing both
the leakage of those pages and (potentially) bad behaviour if a page is
allocated from a pageset while it is being cleared.

Avoid this by factoring out pageset_set_high_and_batch() (which contains 
all needed logic too set a pageset's ->high and ->batch inrespective of 
system state) from zone_pageset_init() and using the new 
pageset_set_high_and_batch() instead of zone_pageset_init() in 
zone_pcp_update().

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
