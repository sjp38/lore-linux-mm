Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 82FFB6B00A9
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 05:26:05 -0400 (EDT)
Date: Mon, 15 Jul 2013 11:25:57 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 7/7] mm: compaction: add compaction to zone_reclaim_mode
Message-ID: <20130715092557.GR4081@redhat.com>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
 <1370445037-24144-8-git-send-email-aarcange@redhat.com>
 <51E097E5.7060308@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51E097E5.7060308@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hush Bensen <hush.bensen@gmail.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Fri, Jul 12, 2013 at 06:57:25PM -0500, Hush Bensen wrote:
> Target reclaim will be done once under low wmark in vanilla kernel,
> however, your patch change it to min wmark, why this behavior change?

This was connected to the previous question, so I tried to answer this
as well in the context of the previous email.

> > +			if (!order)
> > +				goto this_zone_full;
> > +			else
> 
> You do the works should be done in slow path, is it worth?

Not sure to understand the question sorry. The reason for checking
order is that I was skeptical in marking the zone as full, just
because an high order allocation failed. The problem is that if the
cache says "full" and it was just a jitter (like compaction not having
run) , we'll fallback into the other nodes.

In the previous patches however I made compaction a lot more reliable
(no more random skips where compaction isn't even tried for a while
after the cursor meets for example) so maybe I could still mark the
zone full without noticeable effects. The above code has changed in
the meanwhile as I moved the code elsewhere,, so it's better to wait I
send out the new version before reviewing the above further.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
