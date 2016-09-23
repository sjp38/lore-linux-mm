Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 100456B027A
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 22:32:44 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id mi5so180736126pab.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 19:32:44 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id n84si5090811pfj.223.2016.09.22.19.32.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 19:32:43 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping out
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
	<20160922225608.GA3898@kernel.org>
	<1474591086.17726.1.camel@redhat.com>
Date: Fri, 23 Sep 2016 10:32:39 +0800
In-Reply-To: <1474591086.17726.1.camel@redhat.com> (Rik van Riel's message of
	"Thu, 22 Sep 2016 20:38:06 -0400")
Message-ID: <87d1jvuz08.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Shaohua Li <shli@kernel.org>, "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

Rik van Riel <riel@redhat.com> writes:

> On Thu, 2016-09-22 at 15:56 -0700, Shaohua Li wrote:
>> On Wed, Sep 07, 2016 at 09:45:59AM -0700, Huang, Ying wrote:
>> >A 
>> > - It will help the memory fragmentation, especially when the THP is
>> > A  heavily used by the applications.A A The 2M continuous pages will
>> > be
>> > A  free up after THP swapping out.
>> 
>> So this is impossible without THP swapin. While 2M swapout makes a
>> lot of
>> sense, I doubt 2M swapin is really useful. What kind of application
>> is
>> 'optimized' to do sequential memory access?
>
> I suspect a lot of this will depend on the ratio of storage
> speed to CPU & RAM speed.
>
> When swapping to a spinning disk, it makes sense to avoid
> extra memory use on swapin, and work in 4kB blocks.

For spinning disk, the THP swap optimization will be turned off in
current implementation.  Because huge swap cluster allocation based on
swap cluster management, which is available only for non-rotating block
devices (blk_queue_nonrot()).

> When swapping to NVRAM, it makes sense to use 2MB blocks,
> because that storage can handle data faster than we can
> manage 4kB pages in the VM.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
