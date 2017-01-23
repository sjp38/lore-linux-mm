Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E5D66B0038
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 17:54:30 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 201so218566734pfw.5
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 14:54:30 -0800 (PST)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id h1si16970410pln.219.2017.01.23.14.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 14:54:29 -0800 (PST)
Received: by mail-pf0-x22a.google.com with SMTP id y143so44516470pfb.0
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 14:54:29 -0800 (PST)
Date: Mon, 23 Jan 2017 14:54:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: ensure alloc_flags in slow path are initialized
In-Reply-To: <20170123121649.3180300-1-arnd@arndb.de>
Message-ID: <alpine.DEB.2.10.1701231454170.126378@chino.kir.corp.google.com>
References: <20170123121649.3180300-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 23 Jan 2017, Arnd Bergmann wrote:

> The __alloc_pages_slowpath() has gotten rather complex and gcc
> is no longer able to follow the gotos and prove that the
> alloc_flags variable is initialized at the time it is used:
> 
> mm/page_alloc.c: In function '__alloc_pages_slowpath':
> mm/page_alloc.c:3565:15: error: 'alloc_flags' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> To be honest, I can't figure that out either, maybe it is or
> maybe not, but moving the existing initialization up a little
> higher looks safe and makes it obvious to both me and gcc that
> the initialization comes before the first use.
> 
> Fixes: 74eaa4a97e8e ("mm: consolidate GFP_NOFAIL checks in the allocator slowpath")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
