Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 561146B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 08:46:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a17so13434996wme.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 05:46:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 142si10816847wmn.98.2016.05.18.05.46.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 May 2016 05:46:55 -0700 (PDT)
Subject: Re: [RFC 11/13] mm, compaction: add the ultimate direct compaction
 priority
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-12-git-send-email-vbabka@suse.cz>
 <20160513133851.GP20141@dhcp22.suse.cz> <573973F7.7070202@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <573C6418.3010408@suse.cz>
Date: Wed, 18 May 2016 14:46:16 +0200
MIME-Version: 1.0
In-Reply-To: <573973F7.7070202@suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 05/16/2016 09:17 AM, Vlastimil Babka wrote:
>> >Wouldn't it be better to pull the prio check into compaction_deferred
>> >directly? There are more callers and I am not really sure all of them
>> >would behave consistently.
> I'll check, thanks.

Hm so the other callers of compaction_deferred() are in the context 
where there's no direct compaction priority set. They would have to pass 
something like DEF_COMPACT_PRIORITY. That starts getting subtle so I'd 
rather not go that way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
