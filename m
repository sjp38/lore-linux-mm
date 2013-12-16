Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 938C66B007B
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 08:20:21 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id m15so4532809wgh.25
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 05:20:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id z16si2148091wia.34.2013.12.16.05.20.20
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 05:20:20 -0800 (PST)
Message-ID: <52AEFE08.5020501@redhat.com>
Date: Mon, 16 Dec 2013 08:20:08 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/7] mm: page_alloc: Use zone node IDs to approximate
 locality
References: <1386943807-29601-1-git-send-email-mgorman@suse.de> <1386943807-29601-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1386943807-29601-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/13/2013 09:10 AM, Mel Gorman wrote:
> zone_local is using node_distance which is a more expensive call than
> necessary. On x86, it's another function call in the allocator fast path
> and increases cache footprint. This patch makes the assumption zones on a
> local node will share the same node ID. The necessary information should
> already be cache hot.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
