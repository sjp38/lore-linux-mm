Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id AD5D94402ED
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 10:46:10 -0500 (EST)
Received: by wmec201 with SMTP id c201so262396667wme.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 07:46:10 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id m197si6647843wmd.63.2015.11.25.07.46.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 07:46:09 -0800 (PST)
Received: by wmvv187 with SMTP id v187so263125476wmv.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 07:46:09 -0800 (PST)
Date: Wed, 25 Nov 2015 16:46:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/9] mm, page_owner: convert page_owner_inited to
 static key
Message-ID: <20151125154607.GO27283@dhcp22.suse.cz>
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
 <1448368581-6923-4-git-send-email-vbabka@suse.cz>
 <20151125145202.GL27283@dhcp22.suse.cz>
 <5655CEDB.3040205@suse.cz>
 <20151125152533.GC17308@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151125152533.GC17308@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Wed 25-11-15 16:25:33, Peter Zijlstra wrote:
> On Wed, Nov 25, 2015 at 04:08:11PM +0100, Vlastimil Babka wrote:
> > Now I admit I have no idea if there are architectures that don't support jump
> > labels *and* have an expensive atomic read, and whether we care?
> 
> atomic_read() is basically always READ_ONCE(), there's a few archs that
> implement it in asm with a 'weird' load instruction, but its still a
> load. The worst is I think an uncached load for blackfin or somesuch.
> 
> There's plenty archs that do not support the jump label bits, but
> typically you don't care much about those. I'm not aware of an arch that
> cannot fundamentally implement jump_label support if they wanted to.

OK, I see. Thanks for the clarification! Then I do not have any
objections.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
