Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8467E4405BD
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 16:29:08 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id an2so67135291wjc.3
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 13:29:08 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id a34si6551745wrc.277.2017.02.15.13.29.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Feb 2017 13:29:06 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id A617E98DFC
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 21:29:06 +0000 (UTC)
Date: Wed, 15 Feb 2017 21:29:06 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 0/3] Reduce amount of time kswapd sleeps prematurely
Message-ID: <20170215212906.3myab4545wa2f3yc@techsingularity.net>
References: <20170215092247.15989-1-mgorman@techsingularity.net>
 <20170215123055.b8041d7b6bdbcca9c5fd8dd9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170215123055.b8041d7b6bdbcca9c5fd8dd9@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shantanu Goel <sgoel01@yahoo.com>, Chris Mason <clm@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Feb 15, 2017 at 12:30:55PM -0800, Andrew Morton wrote:
> On Wed, 15 Feb 2017 09:22:44 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > This patchset is based on mmots as of Feb 9th, 2016. The baseline is
> > important as there are a number of kswapd-related fixes in that tree and
> > a comparison against v4.10-rc7 would be almost meaningless as a result.
> 
> It's very late to squeeze this into 4.10.  We can make it 4.11 material
> and perhaps tag it for backporting into 4.10.1?

It would be important that Johannes's patches go along with then because
I'm relied on Johannes' fixes to deal with pages being inappropriately
written back from reclaim context when I was analysing the workload.
I'm thinking specifically about these patches

mm-vmscan-scan-dirty-pages-even-in-laptop-mode.patch
mm-vmscan-kick-flushers-when-we-encounter-dirty-pages-on-the-lru.patch
mm-vmscan-kick-flushers-when-we-encounter-dirty-pages-on-the-lru-fix.patch
mm-vmscan-remove-old-flusher-wakeup-from-direct-reclaim-path.patch
mm-vmscan-only-write-dirty-pages-that-the-scanner-has-seen-twice.patch
mm-vmscan-move-dirty-pages-out-of-the-way-until-theyre-flushed.patch
mm-vmscan-move-dirty-pages-out-of-the-way-until-theyre-flushed-fix.patch

This is 4.11 material for sure but I would not automatically try merging
them to 4.10 unless those patches were also included, ideally with a rerun
of just those patches against 4.10 to make sure there are no surprises
lurking in there.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
