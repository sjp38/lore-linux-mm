Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7871082963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 18:55:43 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id n128so22910582pfn.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 15:55:43 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id q74si12276685pfq.207.2016.02.03.15.55.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 15:55:42 -0800 (PST)
Received: by mail-pf0-x22b.google.com with SMTP id 65so23104348pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 15:55:42 -0800 (PST)
Date: Wed, 3 Feb 2016 15:55:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4 02/14] mm, tracing: make show_gfp_flags() up to date
In-Reply-To: <1453812353-26744-3-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1602031555290.10331@chino.kir.corp.google.com>
References: <1453812353-26744-1-git-send-email-vbabka@suse.cz> <1453812353-26744-3-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>

On Tue, 26 Jan 2016, Vlastimil Babka wrote:

> The show_gfp_flags() macro provides human-friendly printing of gfp flags in
> tracepoints. However, it is somewhat out of date and missing several flags.
> This patches fills in the missing flags, and distinguishes properly between
> GFP_ATOMIC and __GFP_ATOMIC which were both translated to "GFP_ATOMIC".
> More generally, all __GFP_X flags which were previously printed as GFP_X, are
> now printed as __GFP_X, since ommiting the underscores results in output that
> doesn't actually match the source code, and can only lead to confusion. Where
> both variants are defined equal (e.g. _DMA and _DMA32), the variant without
> underscores are preferred.
> 
> Also add a note in gfp.h so hopefully future changes will be synced better.
> 
> __GFP_MOVABLE is defined twice in include/linux/gfp.h with different comments.
> Leave just the newer one, which was intended to replace the old one.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Michal Hocko <mhocko@suse.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
