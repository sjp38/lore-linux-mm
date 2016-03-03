Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id D00756B0269
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 02:47:11 -0500 (EST)
Received: by mail-oi0-f46.google.com with SMTP id m82so9846558oif.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:47:11 -0800 (PST)
Received: from mail-ob0-x234.google.com (mail-ob0-x234.google.com. [2607:f8b0:4003:c01::234])
        by mx.google.com with ESMTPS id g3si8089476obr.44.2016.03.02.23.47.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 23:47:10 -0800 (PST)
Received: by mail-ob0-x234.google.com with SMTP id rt7so12893368obb.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:47:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56D71860.7050108@suse.cz>
References: <1456448282-897-1-git-send-email-iamjoonsoo.kim@lge.com>
	<56D71860.7050108@suse.cz>
Date: Thu, 3 Mar 2016 16:47:10 +0900
Message-ID: <CAAmzW4Mj9NVEB5B6-RO-QKgb2Zn4u40vd1OJRCHBja32BWc_0A@mail.gmail.com>
Subject: Re: [PATCH v4 1/2] mm: introduce page reference manipulation functions
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-03-03 1:44 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 02/26/2016 01:58 AM, js1304@gmail.com wrote:
>>
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> Success of CMA allocation largely depends on success of migration
>> and key factor of it is page reference count. Until now, page reference
>> is manipulated by direct calling atomic functions so we cannot follow up
>> who and where manipulate it. Then, it is hard to find actual reason
>> of CMA allocation failure. CMA allocation should be guaranteed to succeed
>> so finding offending place is really important.
>>
>> In this patch, call sites where page reference is manipulated are
>> converted
>> to introduced wrapper function. This is preparation step to add tracepoint
>> to each page reference manipulation function. With this facility, we can
>> easily find reason of CMA allocation failure. There is no functional
>> change
>> in this patch.
>>
>> In addition, this patch also converts reference read sites. It will help
>> a second step that renames page._count to something else and prevents
>> later
>> attempt to direct access to it (Suggested by Andrew).
>>
>> Acked-by: Michal Nazarewicz <mina86@mina86.com>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
>
> Even without Patch 2/2 this is a nice improvement.
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>
> Although somebody might be confused by page_ref_count() vs page_count(). Oh
> well.

Yes... it was pointed by Kirill before but consistency is not the purpose of
this patchset so I skipped it. There are too many sites (roughly 100) so I'm not
sure this code churn is worth doing now. If someone think it is really
important,
I will handle it after rc2.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
