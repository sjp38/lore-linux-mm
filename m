Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1146C6B0005
	for <linux-mm@kvack.org>; Sun,  3 Apr 2016 19:49:00 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id e128so109607703pfe.3
        for <linux-mm@kvack.org>; Sun, 03 Apr 2016 16:49:00 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id g1si37464145pfd.0.2016.04.03.16.48.58
        for <linux-mm@kvack.org>;
        Sun, 03 Apr 2016 16:48:59 -0700 (PDT)
Date: Mon, 4 Apr 2016 08:49:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: vmscan: reclaim highmem zone if buffer_heads is over
 limit
Message-ID: <20160403234903.GA5833@bbox>
References: <1459497658-22203-1-git-send-email-minchan@kernel.org>
 <20160401080350.GB8916@dhcp22.suse.cz>
 <20160401131458.e31d45f56a98c62669b35e3d@linux-foundation.org>
MIME-Version: 1.0
In-Reply-To: <20160401131458.e31d45f56a98c62669b35e3d@linux-foundation.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

On Fri, Apr 01, 2016 at 01:14:58PM -0700, Andrew Morton wrote:
> On Fri, 1 Apr 2016 10:03:50 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Fri 01-04-16 17:00:58, Minchan Kim wrote:
> > [...]
> > > [2] commit 5acbd3bfc93b ("mm, oom: rework oom detection")
> > 
> > I didn't look a tht patch yet but wanted to note that this sha is most
> > probably from linux-next and won't be stable. Also this patch will most
> > likely see some changes in future so making changes on top which should
> > go in independetly will likely just complicate things.
> 
> Yes, we'll need two patches please.  One to fix 6b4f7799c6a5 ("mm:
> vmscan: invoke slab shrinkers from shrink_zone()") (which is in
> mainline) and a second to clean up -mm's "mm, oom: rework oom detection".

Andrew, Michal

Thanks. I just sent out it as separate patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
