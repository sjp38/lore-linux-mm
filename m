Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id A6DD86B00AB
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 14:34:32 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so5917898pde.38
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 11:34:32 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id e6si7554252pbj.343.2014.03.17.11.34.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 11:34:31 -0700 (PDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so5893229pdi.21
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 11:34:31 -0700 (PDT)
Date: Mon, 17 Mar 2014 11:33:32 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch] mm: vmscan: do not swap anon pages just because free+file
 is low
In-Reply-To: <20140317151553.GG14688@cmpxchg.org>
Message-ID: <alpine.LSU.2.11.1403171131420.2475@eggly.anvils>
References: <1394811302-30468-1-git-send-email-hannes@cmpxchg.org> <53232901.5030307@redhat.com> <20140314170807.GW10663@suse.de> <alpine.LSU.2.11.1403152056430.21540@eggly.anvils> <20140317151553.GG14688@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Rafael Aquini <aquini@redhat.com>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 17 Mar 2014, Johannes Weiner wrote:
> On Sat, Mar 15, 2014 at 09:20:16PM -0700, Hugh Dickins wrote:
> > 
> > Hannes, your patch looks reasonable to me, and as I read it would
> > be well complemented by Suleiman's and mine; but I do worry that
> > the "scan_balance = SCAN_ANON" block you're removing was inserted
> > for good reason, and its removal bring complaint from some direction.
> 
> It's been introduced with the original LRU split patch but there is no
> explanation why.  Rik's concern now was that the scan/rotate numbers
> might not be too meaningful with very little cache.
> 
> > By the way, I notice you marked yours for stable [3.12+]:
> > if it's for stable at all, shouldn't it be for 3.9+?
> > (well, maybe nobody's doing a 3.9.N.M but 3.10.N is still alive).
> 
> The code I'm removing is fairly old and it's only been reported to
> create problems starting with the fair zone allocator in 3.12.

Ah, you're right, thanks.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
