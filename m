Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 13D606B040F
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 16:56:57 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id v184so195087961pgv.6
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 13:56:57 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 72si4920597pfj.150.2017.02.15.13.56.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 13:56:56 -0800 (PST)
Date: Wed, 15 Feb 2017 13:56:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] Reduce amount of time kswapd sleeps prematurely
Message-Id: <20170215135654.315cbdca1c403c90a74f1bdd@linux-foundation.org>
In-Reply-To: <20170215212906.3myab4545wa2f3yc@techsingularity.net>
References: <20170215092247.15989-1-mgorman@techsingularity.net>
	<20170215123055.b8041d7b6bdbcca9c5fd8dd9@linux-foundation.org>
	<20170215212906.3myab4545wa2f3yc@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Shantanu Goel <sgoel01@yahoo.com>, Chris Mason <clm@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, 15 Feb 2017 21:29:06 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:

> On Wed, Feb 15, 2017 at 12:30:55PM -0800, Andrew Morton wrote:
> > On Wed, 15 Feb 2017 09:22:44 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:
> > 
> > > This patchset is based on mmots as of Feb 9th, 2016. The baseline is
> > > important as there are a number of kswapd-related fixes in that tree and
> > > a comparison against v4.10-rc7 would be almost meaningless as a result.
> > 
> > It's very late to squeeze this into 4.10.  We can make it 4.11 material
> > and perhaps tag it for backporting into 4.10.1?
> 
> It would be important that Johannes's patches go along with then because
> I'm relied on Johannes' fixes to deal with pages being inappropriately
> written back from reclaim context when I was analysing the workload.
> I'm thinking specifically about these patches
> 
> mm-vmscan-scan-dirty-pages-even-in-laptop-mode.patch
> mm-vmscan-kick-flushers-when-we-encounter-dirty-pages-on-the-lru.patch
> mm-vmscan-kick-flushers-when-we-encounter-dirty-pages-on-the-lru-fix.patch
> mm-vmscan-remove-old-flusher-wakeup-from-direct-reclaim-path.patch
> mm-vmscan-only-write-dirty-pages-that-the-scanner-has-seen-twice.patch
> mm-vmscan-move-dirty-pages-out-of-the-way-until-theyre-flushed.patch
> mm-vmscan-move-dirty-pages-out-of-the-way-until-theyre-flushed-fix.patch
> 
> This is 4.11 material for sure but I would not automatically try merging
> them to 4.10 unless those patches were also included, ideally with a rerun
> of just those patches against 4.10 to make sure there are no surprises
> lurking in there.

Head spinning a bit.  You're saying that if the three patches in the
series "Reduce amount of time kswapd sleeps prematurely" are held off
until 4.11 then the above 6 patches from Johannes should also be held
off for 4.11?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
