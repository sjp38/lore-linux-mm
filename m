Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id F2C196B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 19:17:09 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kl14so5623548pab.6
        for <linux-mm@kvack.org>; Wed, 19 Jun 2013 16:17:09 -0700 (PDT)
Date: Wed, 19 Jun 2013 16:17:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/page_alloc: remove repetitious local_irq_save() in
 __zone_pcp_update()
In-Reply-To: <51C23958.9020108@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1306191615240.17318@chino.kir.corp.google.com>
References: <1371593437-30002-1-git-send-email-cody@linux.vnet.ibm.com> <51C176AC.4000709@linux.vnet.ibm.com> <alpine.DEB.2.02.1306191543070.15308@chino.kir.corp.google.com> <51C23958.9020108@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On Wed, 19 Jun 2013, Cody P Schafer wrote:

> Re-examining this, I've realized that my previous patchset containing
> 	"mm/page_alloc: convert zone_pcp_update() to rely on memory barriers
> instead of stop_machine()"
> 
> already went through and fixed this up (the right way). So ignore this patch.
> 

If you're referring to

mm-page_alloc-factor-out-setting-of-pcp-high-and-pcp-batch.patch
mm-page_alloc-prevent-concurrent-updaters-of-pcp-batch-and-high.patch
mm-page_alloc-insert-memory-barriers-to-allow-async-update-of-pcp-batch-and-high.patch
mm-page_alloc-protect-pcp-batch-accesses-with-access_once.patch
mm-page_alloc-convert-zone_pcp_update-to-rely-on-memory-barriers-instead-of-stop_machine.patch
mm-page_alloc-when-handling-percpu_pagelist_fraction-dont-unneedly-recalulate-high.patch
mm-page_alloc-factor-setup_pageset-into-pageset_init-and-pageset_set_batch.patch
mm-page_alloc-relocate-comment-to-be-directly-above-code-it-refers-to.patch
mm-page_alloc-factor-zone_pageset_init-out-of-setup_zone_pageset.patch
mm-page_alloc-in-zone_pcp_update-uze-zone_pageset_init.patch
mm-page_alloc-rename-setup_pagelist_highmark-to-match-naming-of-pageset_set_batch.patch

from -mm then I'll review them separately because they have their own 
issues.  Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
