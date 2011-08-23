Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 50E0C6B0179
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 05:15:32 -0400 (EDT)
Date: Tue, 23 Aug 2011 05:15:29 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 04/13] mm: new shrinker API
Message-ID: <20110823091529.GC21492@infradead.org>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com>
 <1314089786-20535-5-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1314089786-20535-5-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org

>  /*
>   * A callback you can register to apply pressure to ageable caches.

It's much more than just a single callback these days.

> + * @scan_objects will be made from the current reclaim context.
>   */
>  struct shrinker {
>  	int (*shrink)(struct shrinker *, struct shrink_control *sc);
> +	long (*count_objects)(struct shrinker *, struct shrink_control *sc);
> +	long (*scan_objects)(struct shrinker *, struct shrink_control *sc);

Is shrink_object really such a good name for this method?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
