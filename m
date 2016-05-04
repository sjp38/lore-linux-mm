Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5356E6B007E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 04:50:07 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r12so42807586wme.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 01:50:07 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id m4si3566132wjl.81.2016.05.04.01.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 01:50:06 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id r12so9018779wme.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 01:50:06 -0700 (PDT)
Date: Wed, 4 May 2016 10:50:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0.14] oom detection rework v6
Message-ID: <20160504085004.GC29978@dhcp22.suse.cz>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <20160504054502.GA10899@js1304-P5Q-DELUXE>
 <5729AEFB.9060101@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5729AEFB.9060101@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 04-05-16 10:12:43, Vlastimil Babka wrote:
> On 05/04/2016 07:45 AM, Joonsoo Kim wrote:
> >I still don't agree with some part of this patchset that deal with
> >!costly order. As you know, there was two regression reports from Hugh
> >and Aaron and you fixed them by ensuring to trigger compaction. I
> >think that these show the problem of this patchset. Previous kernel
> >doesn't need to ensure to trigger compaction and just works fine in
> >any case.
> 
> IIRC previous kernel somehow subtly never OOM'd for !costly orders. So
> anything that introduces the possibility of OOM may look like regression for
> some corner case workloads.

The bug fixed by this series was COMPACTION specific because
compaction_ready is not considered otherwise.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
