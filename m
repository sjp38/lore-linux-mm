Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 295BC6B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 11:00:50 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w143so16527901wmw.3
        for <linux-mm@kvack.org>; Tue, 10 May 2016 08:00:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pb3si3087594wjb.73.2016.05.10.08.00.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 08:00:47 -0700 (PDT)
Subject: Re: [PATCH 2/6] mm/page_owner: initialize page owner without holding
 the zone lock
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1462252984-8524-3-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5731F79E.6040606@suse.cz>
Date: Tue, 10 May 2016 17:00:46 +0200
MIME-Version: 1.0
In-Reply-To: <1462252984-8524-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/03/2016 07:23 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> It's not necessary to initialized page_owner with holding the zone lock.
> It would cause more contention on the zone lock although it's not
> a big problem since it is just debug feature. But, it is better
> than before so do it. This is also preparation step to use stackdepot
> in page owner feature. Stackdepot allocates new pages when there is no
> reserved space and holding the zone lock in this case will cause deadlock.

I have same concerns here as for Patch 1/6.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
