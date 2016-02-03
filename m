Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D298882963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 18:54:20 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id o185so23043915pfb.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 15:54:20 -0800 (PST)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id h6si12337855pfd.5.2016.02.03.15.54.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 15:54:20 -0800 (PST)
Received: by mail-pf0-x236.google.com with SMTP id n128so22876619pfn.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 15:54:20 -0800 (PST)
Date: Wed, 3 Feb 2016 15:54:18 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4 01/14] tracepoints: move trace_print_flags definitions
 to tracepoint-defs.h
In-Reply-To: <1453812353-26744-2-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1602031554060.10331@chino.kir.corp.google.com>
References: <1453812353-26744-1-git-send-email-vbabka@suse.cz> <1453812353-26744-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>

On Tue, 26 Jan 2016, Vlastimil Babka wrote:

> The following patch will need to declare array of struct trace_print_flags
> in a header. To prevent this header from pulling in all of RCU through
> trace_events.h, move the struct trace_print_flags{_64} definitions to the new
> lightweight tracepoint-defs.h header.
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
