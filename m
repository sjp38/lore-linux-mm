Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 005AA6B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 15:41:49 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 68so51155376lfq.2
        for <linux-mm@kvack.org>; Wed, 04 May 2016 12:41:48 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id m7si7115227wmc.30.2016.05.04.12.41.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 12:41:47 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n129so12665977wmn.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 12:41:47 -0700 (PDT)
Date: Wed, 4 May 2016 21:41:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/6] mm/page_owner: use stackdepot to store stacktrace
Message-ID: <20160504194146.GF21490@dhcp22.suse.cz>
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1462252984-8524-7-git-send-email-iamjoonsoo.kim@lge.com>
 <20160503085356.GD28039@dhcp22.suse.cz>
 <20160504021449.GA10256@js1304-P5Q-DELUXE>
 <20160504092133.GG29978@dhcp22.suse.cz>
 <CAAmzW4NYWaNvC5MPR8RwQSiKP2b2Z5wVy9nnNxc+sTVWvQ6BGA@mail.gmail.com>
 <CAAmzW4MNNNMwBtfT9Zc2bnJTrDkC=bc-x0b5gpM74E1Mb0uh4w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4MNNNMwBtfT9Zc2bnJTrDkC=bc-x0b5gpM74E1Mb0uh4w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 05-05-16 00:45:45, Joonsoo Kim wrote:
> 2016-05-05 0:30 GMT+09:00 Joonsoo Kim <js1304@gmail.com>:
> > 2016-05-04 18:21 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> >> On Wed 04-05-16 11:14:50, Joonsoo Kim wrote:
> >>> On Tue, May 03, 2016 at 10:53:56AM +0200, Michal Hocko wrote:
> >>> > On Tue 03-05-16 14:23:04, Joonsoo Kim wrote:
> >> [...]
> >>> > > Memory saving looks as following. (Boot 4GB memory system with page_owner)
> >>> > >
> >>> > > 92274688 bytes -> 25165824 bytes
> >>> >
> >>> > It is not clear to me whether this is after a fresh boot or some workload
> >>> > which would grow the stack depot as well. What is a usual cap for the
> >>> > memory consumption.
> >>>
> >>> It is static allocation size after a fresh boot. I didn't add size of
> >>> dynamic allocation memory so it could be larger a little. See below line.
> >>> >
> >>> > > 72% reduction in static allocation size. Even if we should add up size of
> >>> > > dynamic allocation memory, it would not that big because stacktrace is
> >>> > > mostly duplicated.
> >>
> >> This would be true only if most of the allocation stacks are basically
> >> same after the boot which I am not really convinced is true. But you are
> >> right that the number of sublicates will grow only a little. I was
> >> interested about how much is that little ;)
> >
> > After a fresh boot, it just uses 14 order-2 pages.
> 
> I missed to add other information. Even after building the kernel,
> it takes 20 order-2 pages. 20 * 4 * 4KB = 320 KB.

Something like that would be useful to mention in the changelog because
measuring right after the fresh boot without any reasonable workload
sounds suspicious.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
