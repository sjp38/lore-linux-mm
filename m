Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 58E86828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 02:49:32 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id s63so454860330ioi.1
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 23:49:32 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id j27si2232490ioi.109.2016.07.05.23.49.30
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 23:49:31 -0700 (PDT)
Date: Wed, 6 Jul 2016 15:50:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch for-4.7] mm, compaction: prevent VM_BUG_ON when
 terminating freeing scanner
Message-ID: <20160706065016.GA16614@bbox>
References: <alpine.DEB.2.10.1606291436300.145590@chino.kir.corp.google.com>
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1606291436300.145590@chino.kir.corp.google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@techsingularity.net, stable@vger.kernel.org, vbabka@suse.cz

On Wed, Jun 29, 2016 at 02:47:20PM -0700, David Rientjes wrote:
> It's possible to isolate some freepages in a pageblock and then fail 
> split_free_page() due to the low watermark check.  In this case, we hit 
> VM_BUG_ON() because the freeing scanner terminated early without a 
> contended lock or enough freepages.
> 
> This should never have been a VM_BUG_ON() since it's not a fatal 
> condition.  It should have been a VM_WARN_ON() at best, or even handled 
> gracefully.
> 
> Regardless, we need to terminate anytime the full pageblock scan was not 
> done.  The logic belongs in isolate_freepages_block(), so handle its state
> gracefully by terminating the pageblock loop and making a note to restart 
> at the same pageblock next time since it was not possible to complete the 
> scan this time.
> 
> Reported-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: David Rientjes <rientjes@google.com>
Tested-by: Minchan Kim <minchan@kernel.org>

I don't know you sill send updated version based on Joonsoo again.
Anyway, this patch itself doesn't trigger VM_BUG_ON in my test. 

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
