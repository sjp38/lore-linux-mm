Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 57CA46B0074
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 07:47:08 -0400 (EDT)
Received: by wgen6 with SMTP id n6so47710911wge.3
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 04:47:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 8si19071380wjx.16.2015.04.24.04.47.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 04:47:06 -0700 (PDT)
Message-ID: <553A2D38.2050202@suse.cz>
Date: Fri, 24 Apr 2015 13:47:04 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch] mm: vmscan: invoke slab shrinkers from shrink_zone()
References: <1416939830-20289-1-git-send-email-hannes@cmpxchg.org> <20141128160637.GH6948@esperanza> <20150416035736.GA1203@js1304-P5Q-DELUXE> <20150416143413.GA9228@cmpxchg.org> <20150417050653.GA25530@js1304-P5Q-DELUXE>
In-Reply-To: <20150417050653.GA25530@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/17/2015 07:06 AM, Joonsoo Kim wrote:
> On Thu, Apr 16, 2015 at 10:34:13AM -0400, Johannes Weiner wrote:
>> Hi Joonsoo,
>>
>> On Thu, Apr 16, 2015 at 12:57:36PM +0900, Joonsoo Kim wrote:
>>> Hello, Johannes.
>>>
>>> Ccing Vlastimil, because this patch causes some regression on
>>> stress-highalloc test in mmtests and he is a expert on compaction
>>> and would have interest on it. :)

Thanks. It's not the first case when stress-highalloc indicated a 
regression due to changes in reclaim, and some (not really related) 
change to compaction code undid the apparent regression. But one has to 
keep in mind that the benchmark is far from perfect. Thanks for the 
investigation though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
