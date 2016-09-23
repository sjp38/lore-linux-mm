Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6E89D6B0276
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 08:06:32 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b130so15457144wmc.2
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 05:06:32 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id w2si3062835wmw.0.2016.09.23.05.06.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 05:06:31 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id l132so2466308wmf.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 05:06:30 -0700 (PDT)
Date: Fri, 23 Sep 2016 14:06:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/4] mm, compaction: more reliably increase direct
 compaction priority
Message-ID: <20160923120629.GL4478@dhcp22.suse.cz>
References: <20160906135258.18335-3-vbabka@suse.cz>
 <20160921171348.GF24210@dhcp22.suse.cz>
 <f1670976-b4da-5d2c-0a85-37f9a87d6868@suse.cz>
 <20160922140821.GG11875@dhcp22.suse.cz>
 <20160922145237.GH11875@dhcp22.suse.cz>
 <1f47ebe3-61bc-ba8a-defb-9fd8e78614d7@suse.cz>
 <005b01d2154f$8d38b830$a7aa2890$@alibaba-inc.com>
 <98b0c783-28dc-62c4-5a94-74c9e27bebe0@suse.cz>
 <20160923082312.GD4478@dhcp22.suse.cz>
 <03ee39d2-1bf2-802f-deca-5379f73fecfb@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <03ee39d2-1bf2-802f-deca-5379f73fecfb@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Arkadiusz Miskiewicz' <a.miskiewicz@gmail.com>, 'Ralf-Peter Rohbeck' <Ralf-Peter.Rohbeck@quantum.com>, 'Olaf Hering' <olaf@aepfle.de>, linux-kernel@vger.kernel.org, 'Linus Torvalds' <torvalds@linux-foundation.org>, linux-mm@kvack.org, 'Mel Gorman' <mgorman@techsingularity.net>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, 'David Rientjes' <rientjes@google.com>, 'Rik van Riel' <riel@redhat.com>

On Fri 23-09-16 12:47:23, Vlastimil Babka wrote:
> On 09/23/2016 10:23 AM, Michal Hocko wrote:
> > On Fri 23-09-16 08:55:33, Vlastimil Babka wrote:
> > [...]
> >> >From 1623d5bd441160569ffad3808aeeec852048e558 Mon Sep 17 00:00:00 2001
> >> From: Vlastimil Babka <vbabka@suse.cz>
> >> Date: Thu, 22 Sep 2016 17:02:37 +0200
> >> Subject: [PATCH] mm, page_alloc: pull no_progress_loops update to
> >>  should_reclaim_retry()
> >>
> >> The should_reclaim_retry() makes decisions based on no_progress_loops, so it
> >> makes sense to also update the counter there. It will be also consistent with
> >> should_compact_retry() and compaction_retries. No functional change.
> >>
> >> [hillf.zj@alibaba-inc.com: fix missing pointer dereferences]
> >> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> >> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> > 
> > OK, this looks reasonable to me. Could you post both patches in a
> 
> Both? I would argue that [1] might be relevant because it resets the
> number of retries. Only the should_reclaim_retry() cleanup is not
> stricly needed.

Even if it is needed which I am not really sure about it would be
easier to track than in the middle of another thread.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
