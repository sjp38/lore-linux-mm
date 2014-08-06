Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4026B0035
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 18:26:38 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so4142243pad.23
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 15:26:37 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id rn13si1873569pab.178.2014.08.06.15.26.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 Aug 2014 15:26:37 -0700 (PDT)
Received: by mail-pd0-f176.google.com with SMTP id y10so4007018pdj.7
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 15:26:36 -0700 (PDT)
Date: Wed, 6 Aug 2014 15:26:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/4] mm: page_alloc: determine migratetype only once
In-Reply-To: <1407333356-30928-2-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.02.1408061526250.13545@chino.kir.corp.google.com>
References: <1407333356-30928-1-git-send-email-vbabka@suse.cz> <1407333356-30928-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, 6 Aug 2014, Vlastimil Babka wrote:

> The check for ALLOC_CMA in __alloc_pages_nodemask() derives migratetype
> from gfp_mask in each retry pass, although the migratetype variable already
> has the value determined and it does not change. Use the variable and perform
> the check only once. Also convert #ifdef CONFIC_CMA to IS_ENABLED.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
