Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C55B46B025F
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 08:26:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p129so33378788wmp.3
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 05:26:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y70si9847095wme.88.2016.07.22.05.26.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 05:26:21 -0700 (PDT)
Subject: Re: [RFC PATCH 1/2] mempool: do not consume memory reserves from the
 reclaim path
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-1-git-send-email-mhocko@kernel.org>
 <20160719135426.GA31229@cmpxchg.org>
 <alpine.DEB.2.10.1607191315400.58064@chino.kir.corp.google.com>
 <20160720081541.GF11249@dhcp22.suse.cz>
 <alpine.DEB.2.10.1607201353230.22427@chino.kir.corp.google.com>
 <20160721085202.GC26379@dhcp22.suse.cz> <20160721121300.GA21806@cmpxchg.org>
 <20160721145309.GR26379@dhcp22.suse.cz> <20160722063720.GB794@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <15177f2d-cd00-dade-fc25-12a0c241e8f5@suse.cz>
Date: Fri, 22 Jul 2016 14:26:19 +0200
MIME-Version: 1.0
In-Reply-To: <20160722063720.GB794@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com

On 07/22/2016 08:37 AM, Michal Hocko wrote:
> On Thu 21-07-16 16:53:09, Michal Hocko wrote:
>> From d64815758c212643cc1750774e2751721685059a Mon Sep 17 00:00:00 2001
>> From: Michal Hocko <mhocko@suse.com>
>> Date: Thu, 21 Jul 2016 16:40:59 +0200
>> Subject: [PATCH] Revert "mm, mempool: only set __GFP_NOMEMALLOC if there are
>>  free elements"
>>
>> This reverts commit f9054c70d28bc214b2857cf8db8269f4f45a5e23.
>
> I've noticed that Andrew has already picked this one up. Is anybody
> against marking it for stable?

It would be strange to have different behavior with known regression in 
4.6 and 4.7 stables. Actually, there's still time for 4.7 proper?

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
