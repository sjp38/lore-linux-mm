Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id ADA116B002B
	for <linux-mm@kvack.org>; Sun, 11 Nov 2012 14:18:46 -0500 (EST)
Date: Sun, 11 Nov 2012 17:18:33 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v12 0/7] make balloon pages movable by compaction
Message-ID: <20121111191832.GA4290@x61.redhat.com>
References: <cover.1352656285.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1352656285.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, "Michael S. Tsirkin" <mst@redhat.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>

On Sun, Nov 11, 2012 at 05:01:13PM -0200, Rafael Aquini wrote:
> Change log:
> v12:
>  * Address last suggestions on sorting the barriers usage out      (Mel Gorman);
>  * Fix reported build breakages for CONFIG_BALLOON_COMPACTION=n (Andrew Morton);
>  * Enhance commentary on the locking scheme used for balloon page compaction;
>  * Move all the 'balloon vm_event counter' changes to PATCH 07;

Andrew, 

could you drop the earlier review (v11) and pick this submission (v12) instead,
please?


Aside: before submitting I rebased the series on -next-20121109, after reverting
the v11 commits, to make those clean-up hunks from PATCH 01 apply smoothly.

-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
