Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7A08A6B0038
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 02:05:24 -0400 (EDT)
Received: by pabws5 with SMTP id ws5so13443439pab.3
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 23:05:24 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id qx6si19046841pab.180.2015.10.14.23.05.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Oct 2015 23:05:23 -0700 (PDT)
Date: Thu, 15 Oct 2015 15:06:12 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 9/9] mm/compaction: new threshold for compaction
 depleted zone
Message-ID: <20151015060612.GD7566@js1304-P5Q-DELUXE>
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1440382773-16070-10-git-send-email-iamjoonsoo.kim@lge.com>
 <561E4A6F.5070801@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <561E4A6F.5070801@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

On Wed, Oct 14, 2015 at 02:28:31PM +0200, Vlastimil Babka wrote:
> On 08/24/2015 04:19 AM, Joonsoo Kim wrote:
> > Now, compaction algorithm become powerful. Migration scanner traverses
> > whole zone range. So, old threshold for depleted zone which is designed
> > to imitate compaction deferring approach isn't appropriate for current
> > compaction algorithm. If we adhere to current threshold, 1, we can't
> > avoid excessive overhead caused by compaction, because one compaction
> > for low order allocation would be easily successful in any situation.
> > 
> > This patch re-implements threshold calculation based on zone size and
> > allocation requested order. We judge whther compaction possibility is
> > depleted or not by number of successful compaction. Roughly, 1/100
> > of future scanned area should be allocated for high order page during
> > one comaction iteration in order to determine whether zone's compaction
> > possiblity is depleted or not.
> 
> Finally finishing my review, sorry it took that long...
> 

Ah... I forgot to mention that I really appreciate your help.
Thanks for review!!


Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
