Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 2878E6B0068
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 02:11:44 -0400 (EDT)
Date: Wed, 7 Aug 2013 02:11:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/4] mm, rmap: minimize lock hold when unlink_anon_vmas
Message-ID: <20130807061138.GK1845@cmpxchg.org>
References: <1375778620-31593-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375778620-31593-3-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375778620-31593-3-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>

On Tue, Aug 06, 2013 at 05:43:39PM +0900, Joonsoo Kim wrote:
> Currently, we free the avc objects with holding a lock. To minimize
> lock hold time, we just move the avc objects to another list
> with holding a lock. Then, iterate them and free objects without holding
> a lock. This makes lock hold time minimized.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

I expect kfree() to be fast enough that we don't think we need to
bother batching this outside the lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
