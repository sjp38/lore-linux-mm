Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 57CC16B0008
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 17:21:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d5so5237896pfn.12
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 14:21:32 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a77si5499698pfg.300.2018.03.22.14.21.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 14:21:31 -0700 (PDT)
Date: Thu, 22 Mar 2018 17:21:28 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] mm, vmscan, tracing: Use pointer to reclaim_stat struct
 in trace event
Message-ID: <20180322172128.41959c1d@gandalf.local.home>
In-Reply-To: <20180322141022.f02476e1f76338ab9cecf62e@linux-foundation.org>
References: <20180322121003.4177af15@gandalf.local.home>
	<20180322141022.f02476e1f76338ab9cecf62e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Alexei Starovoitov <ast@fb.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Thu, 22 Mar 2018 14:10:22 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> Unfortunately this is not a good time.  Andrey's "mm/vmscan: replace
> mm_vmscan_lru_shrink_inactive with shrink_page_list tracepoint" mucks
> with this code quite a lot and that patch's series is undergoing review
> at present, with a few issues yet unresolved.
> 
> I'll park your patch for now and if Andrey's series doesn't converge
> soon I'll merge this and will ask Andrey to redo things.

No problem. I can easily update that patch on top, as it didn't take
much effort to write and test it. Just let me know if you do pull in
Andrey's work and I need to do the update.

Thanks!

-- Steve
