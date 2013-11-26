Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f44.google.com (mail-bk0-f44.google.com [209.85.214.44])
	by kanga.kvack.org (Postfix) with ESMTP id 30A366B0031
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 15:58:22 -0500 (EST)
Received: by mail-bk0-f44.google.com with SMTP id d7so2819101bkh.17
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 12:58:21 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id s9si11300244bkp.16.2013.11.26.12.58.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 12:58:21 -0800 (PST)
Date: Tue, 26 Nov 2013 15:57:41 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 7/9] mm: thrash detection-based file cache sizing
Message-ID: <20131126205741.GF22729@cmpxchg.org>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
 <1385336308-27121-8-git-send-email-hannes@cmpxchg.org>
 <5293FFC7.5070907@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5293FFC7.5070907@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ryan Mallon <rmallon@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 26, 2013 at 12:56:23PM +1100, Ryan Mallon wrote:
> > + *   fault ------------------------+
> > + *                                 |
> > + *              +--------------+   |            +-------------+
> > + *   reclaim <- |   inactive   | <-+-- demotion |    active   | <--+
> > + *              +--------------+                +-------------+    |
> > + *                     |                                           |
> > + *                     +-------------- promotion ------------------+
> > + *
> > + *
> > + *		Access frequency and refault distance
> > + *
> > + * A workload is trashing when its pages are frequently used but they
> 
> "thrashing".

Thanks ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
