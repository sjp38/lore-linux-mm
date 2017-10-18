Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A00CD6B0069
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 04:38:16 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l10so1835459wmg.5
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 01:38:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 195si7964410wmq.131.2017.10.18.01.38.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Oct 2017 01:38:15 -0700 (PDT)
Subject: Re: [PATCH] mm, page_alloc: simplify hot/cold page handling in
 rmqueue_bulk()
References: <20171018073528.30982-1-vbabka@suse.cz>
 <20171018080631.7ebimdlwek4inits@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d1f1fb5d-6f93-9a9b-bde1-491f4ebf29e0@suse.cz>
Date: Wed, 18 Oct 2017 10:38:14 +0200
MIME-Version: 1.0
In-Reply-To: <20171018080631.7ebimdlwek4inits@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On 10/18/2017 10:06 AM, Mel Gorman wrote:
> On Wed, Oct 18, 2017 at 09:35:28AM +0200, Vlastimil Babka wrote:
>> The code for filling the pcplists in order determined by the cold flag also
>> seems unnecessarily hard to follow. It's sufficient to either use list_add()
>> or list_add_tail(), but the current code also updates the list head pointer
>> in each step to the last added page, which then counterintuitively requires
>> to switch the usage of list_add() and list_add_tail() to achieve the desired
>> order, with no apparent benefit. This patch simplifies the code.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> 
> The "cold" treatment is dubious because almost everything that frees
> considers the page "hot" which limits the usefulness of hot/cold in the
> allocator. While I do not see a problem with your patch as such, please
> take a look at "mm: Remove __GFP_COLD" in particular. The last 4 patches
> in that series make a number of observations on how "cold" is treated in
> the allocator.

Ah, somehow I managed to miss that series, thanks for pointing me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
