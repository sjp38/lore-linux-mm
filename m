Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4A36B0062
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 15:02:56 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id tr6so5792314ieb.17
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 12:02:56 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id cr6si2771099igb.30.2014.09.10.12.02.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 12:02:55 -0700 (PDT)
Received: by mail-ie0-f178.google.com with SMTP id tp5so9046539ieb.37
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 12:02:55 -0700 (PDT)
Date: Wed, 10 Sep 2014 12:02:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: page_alloc: Make paranoid check in move_freepages
 a VM_BUG_ON
In-Reply-To: <20140909145228.GB12309@suse.de>
Message-ID: <alpine.DEB.2.02.1409101202400.27173@chino.kir.corp.google.com>
References: <20140909145228.GB12309@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linuxfoundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 9 Sep 2014, Mel Gorman wrote:

> Since 2.6.24 there has been a paranoid check in move_freepages that looks
> up the zone of two pages. This is a very slow path and the only time I've
> seen this bug trigger recently is when memory initialisation was broken
> during patch development. Despite the fact it's a slow path, this patch
> converts the check to a VM_BUG_ON anyway as it is served its purpose by now.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
