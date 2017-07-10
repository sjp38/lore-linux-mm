Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 159716B049A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 08:30:32 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u30so23820118wrc.9
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 05:30:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s74si6430735wmb.51.2017.07.10.05.30.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 05:30:31 -0700 (PDT)
Date: Mon, 10 Jul 2017 14:30:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, memory_hotplug: remove zone restrictions
Message-ID: <20170710123028.GH19185@dhcp22.suse.cz>
References: <20170629073509.623-1-mhocko@kernel.org>
 <20170629073509.623-3-mhocko@kernel.org>
 <64e889ae-24ab-b845-5751-978a76dd0dd9@suse.cz>
 <20170710064540.GA19185@dhcp22.suse.cz>
 <24c3606d-837a-266d-a294-7e100d1430f0@suse.cz>
 <20170710111750.GG19185@dhcp22.suse.cz>
 <cd2352fb-9831-d0f1-5cb8-b081b292eb38@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cd2352fb-9831-d0f1-5cb8-b081b292eb38@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Mon 10-07-17 14:12:09, Vlastimil Babka wrote:
> On 07/10/2017 01:17 PM, Michal Hocko wrote:
> > On Mon 10-07-17 13:11:29, Vlastimil Babka wrote:
> >> On 07/10/2017 08:45 AM, Michal Hocko wrote:
> >>> On Fri 07-07-17 17:02:59, Vlastimil Babka wrote:
> >>>> [+CC linux-api]
> >>>>
> >>>>
> >>>> Hm so previously, blocks 37-41 would only allow Movable at this point, right?
> >>>
> >>> yes
> >>>
> >>>> Shouldn't we still default to Movable for them? We might be breaking some
> >>>> existing userspace here.
> >>>
> >>> I do not think so. Prior to this merge window f1dd2cd13c4b ("mm,
> >>> memory_hotplug: do not associate hotadded memory to zones until online")
> >>> we allowed only the last offline or the adjacent to existing movable
> >>> memory block to be onlined movable. So the above wasn't possible.
> >>
> >> Not exactly the above, but let's say 1-34 is onlined as Normal, 35-37 is
> >> Movable. Then the only possible action before would be online 38 as
> >> Movable? Now it defaults to Normal?
> > 
> > Yes. And let me repeat you couldn't onlne 35-37 as movable before. So no
> > userspace could depend on that before the rework. Or do I still miss
> > your point?
> 
> Ah, I see. "the last offline or the adjacent to existing movable". OK then.
> 
> It would be indeed better to not change behavour twice then and merge
> this to 4.13, but it's the middle of merge window, so it's not simple...

yeah. I was thinking about about how to make the change reasonably
incremental but failed to find a way. I also didn't want to bring too
many changes at once (the code base is just too fragile already).

If there is a general consensus about the semantic we might want to push
the patch this week. I just do not want to rush it too much as this is a
users visible change and it might kick us back in future.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
