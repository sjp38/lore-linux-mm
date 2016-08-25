Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 869876B026A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:22:24 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u81so27617674wmu.3
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 00:22:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gf6si12495069wjb.72.2016.08.25.00.22.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Aug 2016 00:22:23 -0700 (PDT)
Date: Thu, 25 Aug 2016 09:22:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM killer changes
Message-ID: <20160825072219.GD4230@dhcp22.suse.cz>
References: <8008b7de-9728-a93c-e3d7-30d4ebeba65a@Quantum.com>
 <0606328a-1b14-0bc9-51cb-36621e3e8758@suse.cz>
 <e867d795-224f-5029-48c9-9ce515c0b75f@Quantum.com>
 <f050bc92-d2f1-80cc-f450-c5a57eaf82f0@suse.cz>
 <ea18e6b3-9d47-b154-5e12-face50578302@Quantum.com>
 <f7a9ea9d-bb88-bfd6-e340-3a933559305a@suse.cz>
 <20160819073359.GA32619@dhcp22.suse.cz>
 <d443b884-87e7-1c93-8684-3a3a35759fb1@suse.cz>
 <20160819082639.GE32619@dhcp22.suse.cz>
 <a43170bc-4464-487f-140b-966f58f9bddf@Quantum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a43170bc-4464-487f-140b-966f58f9bddf@Quantum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed 24-08-16 11:13:31, Ralf-Peter Rohbeck wrote:
> On 19.08.2016 01:26, Michal Hocko wrote:
[...]
> > > diff --git a/mm/compaction.c b/mm/compaction.c
> > > index ae4f40afcca1..3e35fce2cace 100644
> > > --- a/mm/compaction.c
> > > +++ b/mm/compaction.c
> > > @@ -1644,8 +1644,8 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
> > >   		.alloc_flags = alloc_flags,
> > >   		.classzone_idx = classzone_idx,
> > >   		.direct_compaction = true,
> > > -		.whole_zone = (prio == COMPACT_PRIO_SYNC_FULL),
> > > -		.ignore_skip_hint = (prio == COMPACT_PRIO_SYNC_FULL)
> > > +		.whole_zone = (prio == MIN_COMPACT_PRIORITY),
> > > +		.ignore_skip_hint = (prio == MIN_COMPACT_PRIORITY)
> > >   	};
> > >   	INIT_LIST_HEAD(&cc.freepages);
> > >   	INIT_LIST_HEAD(&cc.migratepages);
> > > @@ -1691,7 +1691,7 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
> > >   								ac->nodemask) {
> > >   		enum compact_result status;
> > > -		if (prio > COMPACT_PRIO_SYNC_FULL
> > > +		if (prio > MIN_COMPACT_PRIORITY
> > >   					&& compaction_deferred(zone, order)) {
> > >   			rc = max_t(enum compact_result, COMPACT_DEFERRED, rc);
> > >   			continue;
> > > -- 
> > > 2.9.2
> > > 
> > > 
> This change was in linux-next-20160823 so I ran it unmodified.
> 
> I did get an OOM, see attached.

This patch shouldn't make any difference to the previous patch you were
testing. Anyway I do not have the above linux-next tag so I cannot check
what exactly was there. The current code in linux-next contains 
http://lkml.kernel.org/r/20160823074339.GB23577@dhcp22.suse.cz so a
different approach. Once that patch hits the Linus tree we will try to
resurrect the compaction improvements series in linux-next and continue
with the testing.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
