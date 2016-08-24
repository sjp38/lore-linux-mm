Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C41286B0038
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 21:30:36 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id f6so11039605ith.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 18:30:36 -0700 (PDT)
Received: from mail-it0-x22b.google.com (mail-it0-x22b.google.com. [2607:f8b0:4001:c0b::22b])
        by mx.google.com with ESMTPS id n13si7720673ioe.73.2016.08.23.18.30.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 18:30:30 -0700 (PDT)
Received: by mail-it0-x22b.google.com with SMTP id e63so182549387ith.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 18:30:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160824010415.GB27022@bbox>
References: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com> <20160824010415.GB27022@bbox>
From: Hui Zhu <teawater@gmail.com>
Date: Wed, 24 Aug 2016 09:29:49 +0800
Message-ID: <CANFwon3NhwvsWVCVqpudKLyjREuHktzxdEXo5bn0THTjqZ+qLA@mail.gmail.com>
Subject: Re: [RFC 0/4] ZRAM: make it just store the high compression rate page
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hui Zhu <zhuhui@xiaomi.com>, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, Hugh Dickins <hughd@google.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, acme@kernel.org, alexander.shishkin@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, redkoi@virtuozzo.com, luto@kernel.org, kirill.shutemov@linux.intel.com, geliangtang@163.com, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, vdavydov@virtuozzo.com, aarcange@redhat.com, dvlasenk@redhat.com, jmarchan@redhat.com, koct9i@gmail.com, yang.shi@linaro.org, dave.hansen@linux.intel.com, vkuznets@redhat.com, vitalywool@gmail.com, ross.zwisler@linux.intel.com, Thomas Gleixner <tglx@linutronix.de>, kwapulinski.piotr@gmail.com, axboe@fb.com, mchristi@redhat.com, Joe Perches <joe@perches.com>, namit@vmware.com, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Minchan,

On Wed, Aug 24, 2016 at 9:04 AM, Minchan Kim <minchan@kernel.org> wrote:
> Hi Hui,
>
> On Mon, Aug 22, 2016 at 04:25:05PM +0800, Hui Zhu wrote:
>> Current ZRAM just can store all pages even if the compression rate
>> of a page is really low.  So the compression rate of ZRAM is out of
>> control when it is running.
>> In my part, I did some test and record with ZRAM.  The compression rate
>> is about 40%.
>>
>> This series of patches make ZRAM can just store the page that the
>> compressed size is smaller than a value.
>> With these patches, I set the value to 2048 and did the same test with
>> before.  The compression rate is about 20%.  The times of lowmemorykiller
>> also decreased.
>
> I have an interest about the feature for a long time but didn't work on it
> because I didn't have a good idea to implment it with generic approach
> without layer violation. I will look into this after handling urgent works.
>
> Thanks.

That will be great.  Thanks.

Best,
Hui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
