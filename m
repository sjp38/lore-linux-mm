Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CBB9D6B025F
	for <linux-mm@kvack.org>; Wed,  4 May 2016 11:31:42 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 4so111547747pfw.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 08:31:42 -0700 (PDT)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id y56si2067600otd.70.2016.05.04.08.31.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 08:31:33 -0700 (PDT)
Received: by mail-oi0-x22e.google.com with SMTP id k142so69469477oib.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 08:31:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160504092359.GH29978@dhcp22.suse.cz>
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1462252984-8524-7-git-send-email-iamjoonsoo.kim@lge.com>
	<20160503085356.GD28039@dhcp22.suse.cz>
	<20160504021449.GA10256@js1304-P5Q-DELUXE>
	<20160504023500.GB10256@js1304-P5Q-DELUXE>
	<20160504092359.GH29978@dhcp22.suse.cz>
Date: Thu, 5 May 2016 00:31:32 +0900
Message-ID: <CAAmzW4PGnWDz265KLTQFq0LDnuht_V2YXOWMUxHgnfaz1DKswQ@mail.gmail.com>
Subject: Re: [PATCH 6/6] mm/page_owner: use stackdepot to store stacktrace
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2016-05-04 18:23 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> On Wed 04-05-16 11:35:00, Joonsoo Kim wrote:
> [...]
>> Oops... I think more deeply and change my mind. In recursion case,
>> stack is consumed more than 1KB and it would be a problem. I think
>> that best approach is using preallocated per cpu entry. It will also
>> close recursion detection issue by paying interrupt on/off overhead.
>
> I was thinking about per-cpu solution as well but the thing is that the
> stackdepot will allocate and until you drop __GFP_DIRECT_RECLAIM then
> per-cpu is not safe. I haven't checked the implamentation of
> depot_save_stack but I assume it will not schedule in other places.

I will think more.

Thanks for review!

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
