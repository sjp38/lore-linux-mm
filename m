Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 474996B0262
	for <linux-mm@kvack.org>; Tue, 10 May 2016 03:09:43 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s63so5825561wme.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 00:09:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n10si863747wjf.210.2016.05.10.00.09.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 00:09:42 -0700 (PDT)
Subject: Re: [PATCH 0.14] oom detection rework v6
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <20160504054502.GA10899@js1304-P5Q-DELUXE>
 <20160504084737.GB29978@dhcp22.suse.cz>
 <CAAmzW4M7ZT7+vUsW3SrTRSv6Q80B2NdAS+OX7PrnpdrV+=R19A@mail.gmail.com>
 <20160504181608.GA21490@dhcp22.suse.cz>
 <CAAmzW4NM-M39d7qp4B8J87moN3ESVgckbd01=pKXV1XEh6Y+6A@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57318932.3030804@suse.cz>
Date: Tue, 10 May 2016 09:09:38 +0200
MIME-Version: 1.0
In-Reply-To: <CAAmzW4NM-M39d7qp4B8J87moN3ESVgckbd01=pKXV1XEh6Y+6A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/10/2016 08:41 AM, Joonsoo Kim wrote:
> You applied band-aid for CONFIG_COMPACTION and fixed some reported
> problem but it is also fragile. Assume almost pageblock's skipbit are
> set. In this case, compaction easily returns COMPACT_COMPLETE and your
> logic will stop retry. Compaction isn't designed to report accurate
> fragmentation state of the system so depending on it's return value
> for OOM is fragile.

Guess I'll just post a RFC now, even though it's not much tested...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
