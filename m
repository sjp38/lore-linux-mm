Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C3AAD6B0253
	for <linux-mm@kvack.org>; Sat, 23 Jul 2016 14:52:27 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p129so54101730wmp.3
        for <linux-mm@kvack.org>; Sat, 23 Jul 2016 11:52:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id uc1si7365500wjc.93.2016.07.23.11.52.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 23 Jul 2016 11:52:26 -0700 (PDT)
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
 <15177f2d-cd00-dade-fc25-12a0c241e8f5@suse.cz>
 <20160722124448.ad6f9b8be8fe1552b076096c@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <32d24e54-d5de-1b84-7ac3-cc4c41767657@suse.cz>
Date: Sat, 23 Jul 2016 20:52:20 +0200
MIME-Version: 1.0
In-Reply-To: <20160722124448.ad6f9b8be8fe1552b076096c@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com

On 07/22/2016 09:44 PM, Andrew Morton wrote:
> On Fri, 22 Jul 2016 14:26:19 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>> On 07/22/2016 08:37 AM, Michal Hocko wrote:
>>> On Thu 21-07-16 16:53:09, Michal Hocko wrote:
>>>> From d64815758c212643cc1750774e2751721685059a Mon Sep 17 00:00:00 2001
>>>> From: Michal Hocko <mhocko@suse.com>
>>>> Date: Thu, 21 Jul 2016 16:40:59 +0200
>>>> Subject: [PATCH] Revert "mm, mempool: only set __GFP_NOMEMALLOC if there are
>>>>  free elements"
>>>>
>>>> This reverts commit f9054c70d28bc214b2857cf8db8269f4f45a5e23.
>>>
>>> I've noticed that Andrew has already picked this one up. Is anybody
>>> against marking it for stable?
>>
>> It would be strange to have different behavior with known regression in 
>> 4.6 and 4.7 stables. Actually, there's still time for 4.7 proper?
>>
> 
> I added the cc:stable.
> 
> Do we need to bust a gut to rush it into 4.7?  It sounds safer to let
> it bake for a while, fix it in 4.7.1?

Yeah, I guess it's safer to wait now. Would be different if the reverted
commit went in the same cycle.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
