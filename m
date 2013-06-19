Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id B2AD76B0034
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 19:22:32 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 19 Jun 2013 19:22:31 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 322A86E8028
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 19:22:26 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5JNM0IK309864
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 19:22:00 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5JNLxp9019390
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 19:21:59 -0400
Message-ID: <51C23D16.3020805@linux.vnet.ibm.com>
Date: Wed, 19 Jun 2013 16:21:58 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/page_alloc: remove repetitious local_irq_save() in
 __zone_pcp_update()
References: <1371593437-30002-1-git-send-email-cody@linux.vnet.ibm.com> <51C176AC.4000709@linux.vnet.ibm.com> <alpine.DEB.2.02.1306191543070.15308@chino.kir.corp.google.com> <51C23958.9020108@linux.vnet.ibm.com> <alpine.DEB.2.02.1306191615240.17318@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1306191615240.17318@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On 06/19/2013 04:17 PM, David Rientjes wrote:
> On Wed, 19 Jun 2013, Cody P Schafer wrote:
>
>> Re-examining this, I've realized that my previous patchset containing
>> 	"mm/page_alloc: convert zone_pcp_update() to rely on memory barriers
>> instead of stop_machine()"
>>
>> already went through and fixed this up (the right way). So ignore this patch.
>>
>
> If you're referring to
>
> mm-page_alloc-factor-out-setting-of-pcp-high-and-pcp-batch.patch
> mm-page_alloc-prevent-concurrent-updaters-of-pcp-batch-and-high.patch
> mm-page_alloc-insert-memory-barriers-to-allow-async-update-of-pcp-batch-and-high.patch
> mm-page_alloc-protect-pcp-batch-accesses-with-access_once.patch
> mm-page_alloc-convert-zone_pcp_update-to-rely-on-memory-barriers-instead-of-stop_machine.patch
> mm-page_alloc-when-handling-percpu_pagelist_fraction-dont-unneedly-recalulate-high.patch
> mm-page_alloc-factor-setup_pageset-into-pageset_init-and-pageset_set_batch.patch
> mm-page_alloc-relocate-comment-to-be-directly-above-code-it-refers-to.patch
> mm-page_alloc-factor-zone_pageset_init-out-of-setup_zone_pageset.patch
> mm-page_alloc-in-zone_pcp_update-uze-zone_pageset_init.patch
> mm-page_alloc-rename-setup_pagelist_highmark-to-match-naming-of-pageset_set_batch.patch
>
> from -mm then I'll review them separately because they have their own
> issues.  Thanks.
>

I am. You may also want to note
mm-page_alloc-dont-re-init-pageset-in-zone_pcp_update.patch

which fixes a bug in that patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
