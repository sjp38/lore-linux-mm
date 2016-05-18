Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 97F836B0260
	for <linux-mm@kvack.org>; Wed, 18 May 2016 03:19:53 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id u23so86963087vkb.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 00:19:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a194si3598159wma.2.2016.05.18.00.19.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 May 2016 00:19:52 -0700 (PDT)
Subject: Re: [RFC 00/13] make direct compaction more deterministic
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <20160517200131.GA12220@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <573C1795.6070504@suse.cz>
Date: Wed, 18 May 2016 09:19:49 +0200
MIME-Version: 1.0
In-Reply-To: <20160517200131.GA12220@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 05/17/2016 10:01 PM, Michal Hocko wrote:
> Btw. I think that first three patches are nice cleanups and easy enough
> so I would vote for merging them earlier.

I wouldn't mind if patches 1-3 (note: second version of patch 2 posted 
as reply!) went to mmotm now, but it's merge window already, so it's 
unlikely to get into 4.7 anyway?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
