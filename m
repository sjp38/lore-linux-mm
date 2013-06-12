Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 2DF986B0031
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 17:20:34 -0400 (EDT)
Date: Wed, 12 Jun 2013 14:20:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/page_alloc: don't re-init pageset in
 zone_pcp_update()
Message-Id: <20130612142032.882a28b7911ed24ca19e282e@linux-foundation.org>
In-Reply-To: <1370988779-7586-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1370988779-7586-1-git-send-email-cody@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Valdis.Kletnieks@vt.edu

On Tue, 11 Jun 2013 15:12:59 -0700 Cody P Schafer <cody@linux.vnet.ibm.com> wrote:

> Factor pageset_set_high_and_batch() (which contains all needed logic too
> set a pageset's ->high and ->batch inrespective of system state) out of
> zone_pageset_init(), which avoids us calling pageset_init(), and
> unsafely blowing away a pageset at runtime (leaked pages and
> potentially some funky allocations would be the result) when memory
> hotplug is triggered.

This changelog is pretty screwed up :( It tells us what the patch does
but not why it does it.

> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
> ---
> 
> Unless memory hotplug is being triggered on boot, this should *not* be cause of Valdis
> Kletnieks' reported bug in -next:
>          "next-20130607 BUG: Bad page state in process systemd pfn:127643"

And this addendum appears to hint at the info we need.

Please, send a new changelog?  That should include a description of the
user-visible effects of the bug which is being fixed, a description of
why it occurs and a description of how it was fixed.  It would also be
helpful if you can identify which kernel version(s) need the fix.

Also, a Reported-by:Valdis would be appropriate.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
