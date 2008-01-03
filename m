Date: Thu, 3 Jan 2008 02:12:31 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Subject: Re: [PATCH 15 of 24] limit reclaim if enough pages have been freed
Message-ID: <20080103011231.GM30939@v2.random>
References: <patchbomb.1187786927@v2.random> <94686cfcd27347e83a6a.1187786942@v2.random> <20070912055723.c4f79f9a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070912055723.c4f79f9a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 12, 2007 at 05:57:23AM -0700, Andrew Morton wrote:
> whoa, that's a huge change to the scanning logic.  Suppose we've decided to
> scan 1,000,000 active pages and 42 inactive pages.  With this change we'll
> bale out after scanning the 42 inactive pages.  The change to the
> inactive/active balancing logic is potentially large.

Could be, but I don't think it's good to do such an overwork on large
ram systems when freeing swap-cluster-max pages is enough to guarantee
we're not getting spurious oom. It's a latency issue only here (not RT
at all, but still a latency issue). Anyway feel free to keep this
out. It's mostly independent from the rest.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
