Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3E35D6B004F
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 21:00:14 -0500 (EST)
Received: by ywm14 with SMTP id 14so3223390ywm.14
        for <linux-mm@kvack.org>; Thu, 01 Dec 2011 18:00:12 -0800 (PST)
Subject: Re: [PATCH] mm: incorrect overflow check in shrink_slab()
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Xi Wang <xi.wang@gmail.com>
In-Reply-To: <20111201125457.fdf79489.akpm@linux-foundation.org>
Date: Thu, 1 Dec 2011 21:00:08 -0500
Content-Transfer-Encoding: 7bit
Message-Id: <829F10B1-D23B-4CCD-B73F-38501B900DDA@gmail.com>
References: <0D9D9F79-204D-4460-8CE7-A583C5C38A1E@gmail.com> <20111201183202.2e5bd872.kamezawa.hiroyu@jp.fujitsu.com> <20111201125457.fdf79489.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Dec 1, 2011, at 3:54 PM, Andrew Morton wrote:
> Konstantin Khlebnikov's "vmscan: fix initial shrinker size handling"
> does change it to `long'.  That patch is in -mm and linux-next and is
> queued for 3.3.  It was queued for 3.2 but didn't make it due to some
> me/Dave Chinner confusion.

I see.  Cool.  Thanks for the pointer.

- xi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
