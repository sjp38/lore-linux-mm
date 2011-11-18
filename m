Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6E2CD6B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 04:56:49 -0500 (EST)
Date: Fri, 18 Nov 2011 20:56:44 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: remove struct reclaim_state
Message-ID: <20111118095644.GJ7046@dastard>
References: <20111118092806.21688.8662.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111118092806.21688.8662.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Fri, Nov 18, 2011 at 01:28:06PM +0300, Konstantin Khlebnikov wrote:
> Memory reclaimer want to know how much pages was reclaimed during shrinking slabs.
> Currently there is special struct reclaim_state with single counter and pointer from
> task-struct. Let's store counter direcly on task struct and account freed pages
> unconditionally. This will reduce stack usage and simplify code in reclaimer and slab.
> 
> Logic in do_try_to_free_pages() is slightly changed, but this is ok.
> Nobody calls shrink_slab() explicitly before do_try_to_free_pages(),

Except for drop_slab() and shake_page()....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
