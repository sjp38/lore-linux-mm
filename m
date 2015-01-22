Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9020D6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 10:38:45 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id x3so2477951wes.5
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 07:38:45 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id un10si6857125wjc.103.2015.01.22.07.38.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 Jan 2015 07:38:44 -0800 (PST)
Message-ID: <54C11982.9070802@suse.cz>
Date: Thu, 22 Jan 2015 16:38:42 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: compaction: fix the page state calculation in too_many_isolated
References: <1421832864-30643-1-git-send-email-vinmenon@codeaurora.org> <54BF78E3.7030303@suse.cz> <alpine.DEB.2.10.1501211656160.28120@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1501211656160.28120@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, minchan@kernel.org, iamjoonsoo.kim@lge.com

On 01/22/2015 01:58 AM, David Rientjes wrote:
>> I think in case of async compaction, we could skip the safe stuff and just
>> terminate it - it's already done when too_many_isolated returns true, and
>> there's no congestion waiting in that case.
>>
>> So you could extend the too_many_isolated() with "safe" parameter (as you did
>> for vmscan) and pass it "cc->mode != MIGRATE_ASYNC" value from
>> isolate_migrate_block().
>>
>
> Or just pass it struct compact_control *cc and use both cc->zone and
> cc->mode inside this compaction-only function.

Yeah,

in any case, please wait until the discussion about the vmscan fix is 
resolved, before reposting this.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
