Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7C67A82963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 18:58:55 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id w123so23283146pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 15:58:55 -0800 (PST)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id ca7si12224231pad.240.2016.02.03.15.58.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 15:58:54 -0800 (PST)
Received: by mail-pf0-x229.google.com with SMTP id o185so23156899pfb.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 15:58:54 -0800 (PST)
Date: Wed, 3 Feb 2016 15:58:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4 03/14] tools, perf: make gfp_compact_table up to
 date
In-Reply-To: <1453812353-26744-4-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1602031558410.10331@chino.kir.corp.google.com>
References: <1453812353-26744-1-git-send-email-vbabka@suse.cz> <1453812353-26744-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>

On Tue, 26 Jan 2016, Vlastimil Babka wrote:

> When updating tracing's show_gfp_flags() I have noticed that perf's
> gfp_compact_table is also outdated. Fill in the missing flags and place a
> note in gfp.h to increase chance that future updates are synced. Convert the
> __GFP_X flags from "GFP_X" to "__GFP_X" strings in line with the previous
> patch.
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
> Cc: Michal Hocko <mhocko@suse.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
