Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9E76B000A
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 09:47:57 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 1-v6so7713108plv.6
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 06:47:57 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s3-v6si8437124plp.523.2018.03.23.06.47.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 06:47:56 -0700 (PDT)
Date: Fri, 23 Mar 2018 09:47:53 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] mm, vmscan, tracing: Use pointer to reclaim_stat struct
 in trace event
Message-ID: <20180323094753.760b2c86@gandalf.local.home>
In-Reply-To: <20180323134200.GT23100@dhcp22.suse.cz>
References: <20180322121003.4177af15@gandalf.local.home>
	<20180323134200.GT23100@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Alexei Starovoitov <ast@fb.com>

On Fri, 23 Mar 2018 14:42:00 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> Yes, the number of parameter is large. struct reclaim_stat is an
> internal stuff so I didn't want to export it. I do not have strong
> objections to add it somewhere tracing can find it though.

The one solution is to pull the tracing file
include/trace/events/vmscan.h into mm/ and have a local header to store
the reclaim_stat structure that both vmscan.h and vmscan.c can
reference.

I'll make a patch once I hear which way Andrey's patches are going.
That way I don't need to do it twice.

-- Steve
