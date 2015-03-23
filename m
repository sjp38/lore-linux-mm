Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id A95586B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 19:16:23 -0400 (EDT)
Received: by igcau2 with SMTP id au2so41894646igc.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 16:16:23 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com. [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id il2si7273238igb.24.2015.03.23.16.16.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 16:16:23 -0700 (PDT)
Received: by ieclw3 with SMTP id lw3so48206558iec.2
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 16:16:23 -0700 (PDT)
Date: Mon, 23 Mar 2015 16:16:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/compaction: reset compaction scanner positions
In-Reply-To: <1426939106-30347-1-git-send-email-gioh.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1503231613320.24576@chino.kir.corp.google.com>
References: <1426939106-30347-1-git-send-email-gioh.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com

On Sat, 21 Mar 2015, Gioh Kim wrote:

> When the compaction is activated via /proc/sys/vm/compact_memory
> it would better scan the whole zone.
> And some platform, for instance ARM, has the start_pfn of a zone is zero.
> Therefore the first try to compaction via /proc doesn't work.
> It needs to force to reset compaction scanner position at first.
> 
> Signed-off-by: Gioh Kim <gioh.kim@lge.c>

That shouldn't be a valid email address.

> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: David Rientjes <rientjes@google.com>

I was thinking that maybe this would be better handled as part of the 
comapct_zone() logic, i.e. set cc->free_pfn and cc->migrate_pfn based on a 
helper function that understands cc->order == -1 should compact the entire 
zone.  However, after scanning the entire zone as a result of this write, 
the existing cached pfns probably don't matter anymore.  So this seems 
fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
