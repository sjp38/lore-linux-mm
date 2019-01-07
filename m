Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D48D8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 06:47:17 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 82so28253pfs.20
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 03:47:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s36sor37700473pld.52.2019.01.07.03.47.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 03:47:16 -0800 (PST)
Date: Mon, 7 Jan 2019 20:47:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [for-4.9.y] Patch series "use up highorder free pages before OOM"
Message-ID: <20190107114710.GA206194@google.com>
References: <CAMi1Hd0fZwp7WzGhLSmWG3K+DS+nwT9P9o=zAOGRFDDhjpnGpQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMi1Hd0fZwp7WzGhLSmWG3K+DS+nwT9P9o=zAOGRFDDhjpnGpQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amit Pundir <amit.pundir@linaro.org>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Mon, Jan 07, 2019 at 04:37:37PM +0530, Amit Pundir wrote:
> Hi Minchan,
> 
> Kindly review your following mm/OOM upstream fixes for stable 4.9.y.
> 
> 88ed365ea227 ("mm: don't steal highatomic pageblock")
> 04c8716f7b00 ("mm: try to exhaust highatomic reserve before the OOM")
> 29fac03bef72 ("mm: make unreserve highatomic functions reliable")
> 
> One of the patch from this series:
> 4855e4a7f29d ("mm: prevent double decrease of nr_reserved_highatomic")
> has already been picked up for 4.9.y.
> 
> The original patch series https://lkml.org/lkml/2016/10/12/77 was sort
> of NACked for stable https://lkml.org/lkml/2016/10/12/655 because no
> one else reported this OOM behavior on lkml. And the only reason I'm
> bringing this up again, for stable-4.9.y tree, is that msm-4.9 Android
> trees cherry-picked this whole series as is for their production devices.
> 
> Are there any concerns around this series, in case I submit it to
> stable mailing list for v4.9.y?

Actually, it was not NAK. Other MM guy wanted to backport but I didn't
intentionally because I didn't see other reports at that time.

However, after that, I got a private email from some other kernel team
and debugged together. It hit this problem and solved by above patches
so they backported it.
If you say Android already check-picked them, it's third time I heard
the problem(If they really pick those patch due to some problem) since
we merge those patches into upstream.
So, I belive it's worth to merge if someone could volunteer.

Thanks.
