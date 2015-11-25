Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8CAE96B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 10:25:40 -0500 (EST)
Received: by wmuu63 with SMTP id u63so142480459wmu.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 07:25:40 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id y10si35310411wjw.208.2015.11.25.07.25.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 07:25:39 -0800 (PST)
Date: Wed, 25 Nov 2015 16:25:33 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 3/9] mm, page_owner: convert page_owner_inited to
 static key
Message-ID: <20151125152533.GC17308@twins.programming.kicks-ass.net>
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
 <1448368581-6923-4-git-send-email-vbabka@suse.cz>
 <20151125145202.GL27283@dhcp22.suse.cz>
 <5655CEDB.3040205@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5655CEDB.3040205@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Wed, Nov 25, 2015 at 04:08:11PM +0100, Vlastimil Babka wrote:
> Now I admit I have no idea if there are architectures that don't support jump
> labels *and* have an expensive atomic read, and whether we care?

atomic_read() is basically always READ_ONCE(), there's a few archs that
implement it in asm with a 'weird' load instruction, but its still a
load. The worst is I think an uncached load for blackfin or somesuch.

There's plenty archs that do not support the jump label bits, but
typically you don't care much about those. I'm not aware of an arch that
cannot fundamentally implement jump_label support if they wanted to.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
