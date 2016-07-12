Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 024D76B025E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 19:28:13 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ib6so53721612pad.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 16:28:12 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id s88si313063pfa.225.2016.07.12.16.28.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 16:28:12 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id c2so11853311pfa.2
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 16:28:12 -0700 (PDT)
Date: Tue, 12 Jul 2016 16:28:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] mm, meminit: Ensure node is online before checking
 whether pages are uninitialised
In-Reply-To: <1468008031-3848-4-git-send-email-mgorman@techsingularity.net>
Message-ID: <alpine.DEB.2.10.1607121627540.118757@chino.kir.corp.google.com>
References: <1468008031-3848-1-git-send-email-mgorman@techsingularity.net> <1468008031-3848-4-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 8 Jul 2016, Mel Gorman wrote:

> early_page_uninitialised looks up an arbitrary PFN. While a machine without
> node 0 will boot with "mm, page_alloc: Always return a valid node from
> early_pfn_to_nid", it works because it assumes that nodes are always in
> PFN order. This is not guaranteed so this patch adds robustness by always
> checking if the node being checked is online.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Cc: <stable@vger.kernel.org> # 4.2+

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
