Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8532A6B000C
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 09:52:34 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b17so6053421wrf.20
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 06:52:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q62si6017922wma.54.2018.03.23.06.52.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Mar 2018 06:52:28 -0700 (PDT)
Date: Fri, 23 Mar 2018 14:52:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmscan, tracing: Use pointer to reclaim_stat struct
 in trace event
Message-ID: <20180323135225.GV23100@dhcp22.suse.cz>
References: <20180322121003.4177af15@gandalf.local.home>
 <20180323134200.GT23100@dhcp22.suse.cz>
 <20180323094753.760b2c86@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180323094753.760b2c86@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Alexei Starovoitov <ast@fb.com>

On Fri 23-03-18 09:47:53, Steven Rostedt wrote:
> On Fri, 23 Mar 2018 14:42:00 +0100
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > Yes, the number of parameter is large. struct reclaim_stat is an
> > internal stuff so I didn't want to export it. I do not have strong
> > objections to add it somewhere tracing can find it though.
> 
> The one solution is to pull the tracing file
> include/trace/events/vmscan.h into mm/ and have a local header to store
> the reclaim_stat structure that both vmscan.h and vmscan.c can
> reference.

I guess we can live with the public definition as well.

-- 
Michal Hocko
SUSE Labs
