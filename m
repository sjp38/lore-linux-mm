Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B76516B0038
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 21:08:31 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id f6so9251656ith.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 18:08:31 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y12si7616817iod.45.2016.08.23.18.08.19
        for <linux-mm@kvack.org>;
        Tue, 23 Aug 2016 18:08:20 -0700 (PDT)
Date: Wed, 24 Aug 2016 10:04:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 0/4] ZRAM: make it just store the high compression rate page
Message-ID: <20160824010415.GB27022@bbox>
References: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, hughd@google.com, rostedt@goodmis.org, mingo@redhat.com, peterz@infradead.org, acme@kernel.org, alexander.shishkin@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, redkoi@virtuozzo.com, luto@kernel.org, kirill.shutemov@linux.intel.com, geliangtang@163.com, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, vdavydov@virtuozzo.com, aarcange@redhat.com, dvlasenk@redhat.com, jmarchan@redhat.com, koct9i@gmail.com, yang.shi@linaro.org, dave.hansen@linux.intel.com, vkuznets@redhat.com, vitalywool@gmail.com, ross.zwisler@linux.intel.com, tglx@linutronix.de, kwapulinski.piotr@gmail.com, axboe@fb.com, mchristi@redhat.com, joe@perches.com, namit@vmware.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, teawater@gmail.com

Hi Hui,

On Mon, Aug 22, 2016 at 04:25:05PM +0800, Hui Zhu wrote:
> Current ZRAM just can store all pages even if the compression rate
> of a page is really low.  So the compression rate of ZRAM is out of
> control when it is running.
> In my part, I did some test and record with ZRAM.  The compression rate
> is about 40%.
> 
> This series of patches make ZRAM can just store the page that the
> compressed size is smaller than a value.
> With these patches, I set the value to 2048 and did the same test with
> before.  The compression rate is about 20%.  The times of lowmemorykiller
> also decreased.

I have an interest about the feature for a long time but didn't work on it
because I didn't have a good idea to implment it with generic approach
without layer violation. I will look into this after handling urgent works.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
