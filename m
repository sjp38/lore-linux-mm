Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A48746B0024
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 17:10:25 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j12so5224110pff.18
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 14:10:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 97-v6si6873118plm.149.2018.03.22.14.10.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 14:10:24 -0700 (PDT)
Date: Thu, 22 Mar 2018 14:10:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, vmscan, tracing: Use pointer to reclaim_stat struct
 in trace event
Message-Id: <20180322141022.f02476e1f76338ab9cecf62e@linux-foundation.org>
In-Reply-To: <20180322121003.4177af15@gandalf.local.home>
References: <20180322121003.4177af15@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Alexei Starovoitov <ast@fb.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Thu, 22 Mar 2018 12:10:03 -0400 Steven Rostedt <rostedt@goodmis.org> wrote:

> 
> The trace event trace_mm_vmscan_lru_shrink_inactive() currently has 12
> parameters! Seven of them are from the reclaim_stat structure. This
> structure is currently local to mm/vmscan.c. By moving it to the global
> vmstat.h header, we can also reference it from the vmscan tracepoints. In
> moving it, it brings down the overhead of passing so many arguments to the
> trace event. In the future, we may limit the number of arguments that a
> trace event may pass (ideally just 6, but more realistically it may be 8).

Unfortunately this is not a good time.  Andrey's "mm/vmscan: replace
mm_vmscan_lru_shrink_inactive with shrink_page_list tracepoint" mucks
with this code quite a lot and that patch's series is undergoing review
at present, with a few issues yet unresolved.

I'll park your patch for now and if Andrey's series doesn't converge
soon I'll merge this and will ask Andrey to redo things.
