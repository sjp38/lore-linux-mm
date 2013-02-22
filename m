Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 43A1E6B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 15:51:05 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so534445dak.28
        for <linux-mm@kvack.org>; Fri, 22 Feb 2013 12:51:04 -0800 (PST)
Date: Fri, 22 Feb 2013 12:50:25 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/7] ksm: add some comments
In-Reply-To: <5126F360.1060507@gmail.com>
Message-ID: <alpine.LNX.2.00.1302221239450.6100@eggly.anvils>
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils> <alpine.LNX.2.00.1302210018100.17843@eggly.anvils> <5126F360.1060507@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 22 Feb 2013, Ric Mason wrote:
> 
> What's the root reason merge_across_nodes setting just can be changed only
> when there are no ksm shared pages in system?

Simplicity.  Why add code (moving nodes from tree to tree, handling
the collisions) for a rare case that doesn't need to be fast?

> Can they be unmerged and merged again during ksmd scan?

That's more or less what happens, isn't it?  Perhaps you're
asking why the admin has to echo 2 >run; echo 0 >merge; echo 1 >run
instead of that all happening automatically inside the echo 0 > merge?

If I'd implemented it myself, I might have chosen to do it that way;
but neither I nor other reviewers felt strongly enough to change that,
though we could do so.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
