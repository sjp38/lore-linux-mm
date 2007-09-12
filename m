Date: Wed, 12 Sep 2007 15:40:12 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 13 of 24] simplify oom heuristics
Message-ID: <20070912134012.GL21600@v2.random>
References: <patchbomb.1187786927@v2.random> <cd70d64570b9add8072f.1187786940@v2.random> <20070912055240.cb60aeb4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070912055240.cb60aeb4.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 12, 2007 at 05:52:40AM -0700, Andrew Morton wrote:
> I think the idea behind the code which you're removing is to avoid killing
> a computationally-expensive task which we've already invested a lot of CPU
> time in.  IOW, kill the job which has been running for three seconds in
> preference to the one which has been running three weeks.
> 
> That seems like a good strategy to me.

I know... but for certain apps like simulations, the task that goes
oom is one of the longest running ones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
