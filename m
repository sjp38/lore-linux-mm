Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 579766B025F
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 03:27:06 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id v188so74115640wme.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 00:27:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gy10si27329700wjc.115.2016.04.11.00.27.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 00:27:05 -0700 (PDT)
Subject: Re: [PATCH v2 4/4] mm, compaction: direct freepage allocation for
 async direct compaction
References: <1459414236-9219-1-git-send-email-vbabka@suse.cz>
 <1459414236-9219-5-git-send-email-vbabka@suse.cz>
 <20160411071351.GB26116@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570B51C6.4050005@suse.cz>
Date: Mon, 11 Apr 2016 09:27:02 +0200
MIME-Version: 1.0
In-Reply-To: <20160411071351.GB26116@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/11/2016 09:13 AM, Joonsoo Kim wrote:
> On Thu, Mar 31, 2016 at 10:50:36AM +0200, Vlastimil Babka wrote:
>> The goal of direct compaction is to quickly make a high-order page available
>> for the pending allocation. The free page scanner can add significant latency
>> when searching for migration targets, although to succeed the compaction, the
>> only important limit on the target free pages is that they must not come from
>> the same order-aligned block as the migrated pages.
>
> If we fails migration, free pages will remain and they can interfere
> further compaction success because they doesn't come from previous
> order-aligned block but can come from next order-aligned block. You
> need to free remaining freelist after migration attempt fails?

Oh, good point, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
