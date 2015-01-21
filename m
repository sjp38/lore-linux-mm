Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2A98D6B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 17:20:07 -0500 (EST)
Received: by mail-ie0-f175.google.com with SMTP id ar1so13256082iec.6
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 14:20:07 -0800 (PST)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id q3si468046ign.27.2015.01.21.14.20.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 14:20:05 -0800 (PST)
Received: by mail-ig0-f180.google.com with SMTP id b16so17459717igk.1
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 14:20:05 -0800 (PST)
Date: Wed, 21 Jan 2015 14:20:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: vmstat: Fix build error when !CONFIG_PROC_FS
In-Reply-To: <1421753625.7353.0.camel@phoenix>
Message-ID: <alpine.DEB.2.10.1501211419260.2716@chino.kir.corp.google.com>
References: <1421753625.7353.0.camel@phoenix>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Axel Lin <axel.lin@ingics.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

On Tue, 20 Jan 2015, Axel Lin wrote:

> Fix build error when CONFIG_DEBUG_FS && CONFIG_COMPACTION && !CONFIG_PROC_FS:
> 
>   CC      mm/vmstat.o
> mm/vmstat.c:1607:11: error: 'frag_start' undeclared here (not in a function)
> mm/vmstat.c:1608:10: error: 'frag_next' undeclared here (not in a function)
> mm/vmstat.c:1609:10: error: 'frag_stop' undeclared here (not in a function)
> make[1]: *** [mm/vmstat.o] Error 1
> make: *** [mm] Error 2
> 
> Signed-off-by: Axel Lin <axel.lin@ingics.com>

Tested-by: David Rientjes <rientjes@google.com>

Fixes the build error that I saw with linux-next randconfig, but I'm not 
sure how sane a debugfs && !procfs config is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
