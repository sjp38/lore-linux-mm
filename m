Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5FB7E6B0254
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 10:22:46 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id p65so82660989wmp.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 07:22:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d73si5410353wma.57.2016.03.02.07.22.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 07:22:45 -0800 (PST)
Subject: Re: [PATCH v2 4/5] mm, kswapd: replace kswapd compaction with waking
 up kcompactd
References: <1454938691-2197-1-git-send-email-vbabka@suse.cz>
 <1454938691-2197-5-git-send-email-vbabka@suse.cz>
 <20160302063322.GB32695@js1304-P5Q-DELUXE> <56D6BACB.7060005@suse.cz>
 <CAAmzW4PHAsMvifgV2FpS_FYE78_PzDtADvoBY67usc_9-D4Hjg@mail.gmail.com>
 <56D6F41D.9080107@suse.cz>
 <CAAmzW4PGgYkL9xnCXgSQ=8kW0sJkaYyrxenb_XKHcW1wDGMEyw@mail.gmail.com>
 <56D6FB77.2090801@suse.cz>
 <CAAmzW4METKGH27_tcnBLp1CQU3UK+YmfXJ4MwHuwUfqynAp_eg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D70543.60806@suse.cz>
Date: Wed, 2 Mar 2016 16:22:43 +0100
MIME-Version: 1.0
In-Reply-To: <CAAmzW4METKGH27_tcnBLp1CQU3UK+YmfXJ4MwHuwUfqynAp_eg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

On 03/02/2016 03:59 PM, Joonsoo Kim wrote:
> 2016-03-02 23:40 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
>> On 03/02/2016 03:22 PM, Joonsoo Kim wrote:
>>
>> So I understand that patch 5 would be just about this?
>>
>> -       if (compaction_restarting(zone, cc->order) && !current_is_kcompactd())
>> +       if (compaction_restarting(zone, cc->order))
>>                  __reset_isolation_suitable(zone);
>
> Yeah, you understand correctly. :)
>
>> I'm more inclined to fold it in that case.
>
> Patch would be just simple, but, I guess it would cause some difference
> in test result. But, I'm okay for folding.

Thanks. Andrew, should I send now patch folding patch 4/5 and 5/5 with 
all the accumulated fixlets (including those I sent earlier today) and 
combined changelog, or do you want to apply the new fixlets separately 
first and let them sit for a week or so? In any case, sorry for the churn.

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
