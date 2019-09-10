Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B76A4C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 08:29:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A3AF21019
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 08:29:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A3AF21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E99976B0006; Tue, 10 Sep 2019 04:29:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E49B36B0007; Tue, 10 Sep 2019 04:29:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D86C76B0008; Tue, 10 Sep 2019 04:29:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0139.hostedemail.com [216.40.44.139])
	by kanga.kvack.org (Postfix) with ESMTP id B79766B0006
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 04:29:22 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 5D267180AD7C3
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:29:22 +0000 (UTC)
X-FDA: 75918336564.18.space36_178ec6169d814
X-HE-Tag: space36_178ec6169d814
X-Filterd-Recvd-Size: 7892
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:29:21 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 049E2AD73;
	Tue, 10 Sep 2019 08:29:19 +0000 (UTC)
Date: Tue, 10 Sep 2019 10:29:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, l.roehrs@profihost.ag,
	cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: lot of MemAvailable but falling cache and raising PSI
Message-ID: <20190910082919.GL2063@dhcp22.suse.cz>
References: <20190909082732.GC27159@dhcp22.suse.cz>
 <1d9ee19a-98c9-cd78-1e5b-21d9d6e36792@profihost.ag>
 <20190909110136.GG27159@dhcp22.suse.cz>
 <20190909120811.GL27159@dhcp22.suse.cz>
 <88ff0310-b9ab-36b6-d8ab-b6edd484d973@profihost.ag>
 <20190909122852.GM27159@dhcp22.suse.cz>
 <2d04fc69-8fac-2900-013b-7377ca5fd9a8@profihost.ag>
 <20190909124950.GN27159@dhcp22.suse.cz>
 <10fa0b97-631d-f82b-0881-89adb9ad5ded@profihost.ag>
 <52235eda-ffe2-721c-7ad7-575048e2d29d@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52235eda-ffe2-721c-7ad7-575048e2d29d@profihost.ag>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 10-09-19 07:56:36, Stefan Priebe - Profihost AG wrote:
> 
> Am 09.09.19 um 14:56 schrieb Stefan Priebe - Profihost AG:
> > Am 09.09.19 um 14:49 schrieb Michal Hocko:
> >> On Mon 09-09-19 14:37:52, Stefan Priebe - Profihost AG wrote:
> >>>
> >>> Am 09.09.19 um 14:28 schrieb Michal Hocko:
> >>>> On Mon 09-09-19 14:10:02, Stefan Priebe - Profihost AG wrote:
> >>>>>
> >>>>> Am 09.09.19 um 14:08 schrieb Michal Hocko:
> >>>>>> On Mon 09-09-19 13:01:36, Michal Hocko wrote:
> >>>>>>> and that matches moments when we reclaimed memory. There seems to be a
> >>>>>>> steady THP allocations flow so maybe this is a source of the direct
> >>>>>>> reclaim?
> >>>>>>
> >>>>>> I was thinking about this some more and THP being a source of reclaim
> >>>>>> sounds quite unlikely. At least in a default configuration because we
> >>>>>> shouldn't do anything expensinve in the #PF path. But there might be a
> >>>>>> difference source of high order (!costly) allocations. Could you check
> >>>>>> how many allocation requests like that you have on your system?
> >>>>>>
> >>>>>> mount -t debugfs none /debug
> >>>>>> echo "order > 0" > /debug/tracing/events/kmem/mm_page_alloc/filter
> >>>>>> echo 1 > /debug/tracing/events/kmem/mm_page_alloc/enable
> >>>>>> cat /debug/tracing/trace_pipe > $file
> >>>>
> >>>> echo 1 > /debug/tracing/events/vmscan/mm_vmscan_direct_reclaim_begin/enable
> >>>> echo 1 > /debug/tracing/events/vmscan/mm_vmscan_direct_reclaim_end/enable
> >>>>  
> >>>> might tell us something as well but it might turn out that it just still
> >>>> doesn't give us the full picture and we might need
> >>>> echo stacktrace > /debug/tracing/trace_options
> >>>>
> >>>> It will generate much more output though.
> >>>>
> >>>>> Just now or when PSI raises?
> >>>>
> >>>> When the excessive reclaim is happening ideally.
> >>>
> >>> This one is from a server with 28G memfree but memory pressure is still
> >>> jumping between 0 and 10%.
> >>>
> >>> I did:
> >>> echo "order > 0" >
> >>> /sys/kernel/debug/tracing/events/kmem/mm_page_alloc/filter
> >>>
> >>> echo 1 > /sys/kernel/debug/tracing/events/kmem/mm_page_alloc/enable
> >>>
> >>> echo 1 >
> >>> /sys/kernel/debug/tracing/events/vmscan/mm_vmscan_direct_reclaim_begin/enable
> >>>
> >>> echo 1 >
> >>> /sys/kernel/debug/tracing/events/vmscan/mm_vmscan_direct_reclaim_end/enable
> >>>
> >>> timeout 120 cat /sys/kernel/debug/tracing/trace_pipe > /trace
> >>>
> >>> File attached.
> >>
> >> There is no reclaim captured in this trace dump.
> >> $ zcat trace1.gz | sed 's@.*\(order=[0-9]\).*\(gfp_flags=.*\)@\1 \2@' | sort | uniq -c
> >>     777 order=1 gfp_flags=__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC
> >>     663 order=1 gfp_flags=__GFP_IO|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC
> >>     153 order=1 gfp_flags=__GFP_IO|__GFP_NOWARN|__GFP_RETRY_MAYFAIL|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC
> >>     911 order=1 gfp_flags=GFP_KERNEL_ACCOUNT|__GFP_ZERO
> >>    4872 order=1 gfp_flags=GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_ACCOUNT
> >>      62 order=1 gfp_flags=GFP_NOWAIT|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC
> >>      14 order=2 gfp_flags=GFP_ATOMIC|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP
> >>      11 order=2 gfp_flags=GFP_ATOMIC|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_RECLAIMABLE
> >>    1263 order=2 gfp_flags=__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC
> >>      45 order=2 gfp_flags=__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_RECLAIMABLE
> >>       1 order=2 gfp_flags=GFP_KERNEL|__GFP_COMP|__GFP_ZERO
> >>    7853 order=2 gfp_flags=GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_ACCOUNT
> >>      73 order=3 gfp_flags=__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC
> >>     729 order=3 gfp_flags=__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_RECLAIMABLE
> >>     528 order=3 gfp_flags=__GFP_IO|__GFP_NOWARN|__GFP_RETRY_MAYFAIL|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC
> >>    1203 order=3 gfp_flags=GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_ACCOUNT
> >>    5295 order=3 gfp_flags=GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP
> >>       1 order=3 gfp_flags=GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC
> >>     132 order=3 gfp_flags=GFP_NOWAIT|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC
> >>      13 order=5 gfp_flags=GFP_KERNEL|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_ZERO
> >>       1 order=6 gfp_flags=GFP_KERNEL|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_ZERO
> >>    1232 order=9 gfp_flags=GFP_TRANSHUGE
> >>     108 order=9 gfp_flags=GFP_TRANSHUGE|__GFP_THISNODE
> >>     362 order=9 gfp_flags=GFP_TRANSHUGE_LIGHT|__GFP_THISNODE
> >>
> >> Nothing really stands out because except for the THP ones none of others
> >> are going to even be using movable zone.
> > It might be that this is not an ideal example is was just the fastest i
> > could find. May be we really need one with much higher pressure.
> 
> here another trace log where a system has 30GB free memory but is under
> constant pressure and does not build up any file cache caused by memory
> pressure.

So the reclaim is clearly induced by THP allocations
$ zgrep vmscan trace2.gz | grep gfp_flags | sed 's@.*\(gfp_flags=.*\) .*@\1@' | sort | uniq -c
   1580 gfp_flags=GFP_TRANSHUGE
     15 gfp_flags=GFP_TRANSHUGE|__GFP_THISNODE

$ zgrep vmscan trace2.gz | grep nr_reclaimed | sed 's@nr_reclaimed=@@' |  awk '{nr+=$6+0}END{print nr}'
1541726

6GB of memory reclaimed in 1776s. That is a lot! But the THP allocation
rate is really high as well
$ zgrep "page_alloc.*GFP_TRANSHUGE" trace2.gz | wc -l
15340

this is 30GB worth of THPs (some of them might get released of course).
Also only 10% of requests ends up reclaiming.

One additional interesting point
$ zgrep vmscan trace2.gz | grep nr_reclaimed | sed 's@.*nr_reclaimed=\([[0-9]*\)@\1@' | calc_min_max.awk
min: 1.00 max: 2792.00 avg: 965.99 std: 331.12 nr: 1596

Even though the std is high there are quite some outliers when a lot of
memory is reclaimed.

Which kernel version is this. And again, what is the THP configuration.
-- 
Michal Hocko
SUSE Labs

