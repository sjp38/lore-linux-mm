Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0EEB86B000C
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 10:15:52 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c5so6705137pfn.17
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 07:15:52 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z67si6835969pfd.257.2018.03.23.07.15.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 07:15:50 -0700 (PDT)
Date: Fri, 23 Mar 2018 10:15:48 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] mm, vmscan, tracing: Use pointer to reclaim_stat struct
 in trace event
Message-ID: <20180323101548.1f091c93@gandalf.local.home>
In-Reply-To: <20180323135225.GV23100@dhcp22.suse.cz>
References: <20180322121003.4177af15@gandalf.local.home>
	<20180323134200.GT23100@dhcp22.suse.cz>
	<20180323094753.760b2c86@gandalf.local.home>
	<20180323135225.GV23100@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Alexei Starovoitov <ast@fb.com>

On Fri, 23 Mar 2018 14:52:25 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 23-03-18 09:47:53, Steven Rostedt wrote:
> > 
> > The one solution is to pull the tracing file
> > include/trace/events/vmscan.h into mm/ and have a local header to store
> > the reclaim_stat structure that both vmscan.h and vmscan.c can
> > reference.  
> 
> I guess we can live with the public definition as well.
> 

Yes, that would be easier. Thanks!

Then if Andrey's patches are not pulled, then this patch will be good
to go.

-- Steve
