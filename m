Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5ED4D6B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 22:00:14 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id o79so78622567ioo.14
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 19:00:14 -0700 (PDT)
Received: from dggrg02-dlp.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id n14si1513440ioi.95.2017.04.10.19.00.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 19:00:13 -0700 (PDT)
Message-ID: <58EC375F.5040800@huawei.com>
Date: Tue, 11 Apr 2017 09:54:39 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: Page allocator order-0 optimizations merged
References: <58b48b1f.F/jo2/WiSxvvGm/z%akpm@linux-foundation.org> <20170301144845.783f8cad@redhat.com> <58EB9754.3090202@huawei.com> <20170410151051.n4lytmha4tqh4l3t@techsingularity.net>
In-Reply-To: <20170410151051.n4lytmha4tqh4l3t@techsingularity.net>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>, Tariq Toukan <tariqt@mellanox.com>

On 2017/4/10 23:10, Mel Gorman wrote:
> On Mon, Apr 10, 2017 at 10:31:48PM +0800, zhong jiang wrote:
>> Hi, Mel
>>
>>      The patch I had test on arm64. I find the great degradation. I test it by micro-bench.
>>     The patrly data is as following.  and it is stable.  That stands for the allocate and free time. 
>>     
> What type of allocations is the benchmark doing? In particular, what context
> is the microbenchmark allocating from? Lastly, how did you isolate the
> patch, did you test two specific commits in mainline or are you comparing
> 4.10 with 4.11-rcX?
>
 Hi, Mel

   benchmark adopt  0 order allocation.  just insmod module  allocate  memory by alloc_pages.
   it is not interrupt context.  I test the patch in linux 4.1 stable. In x86 , it have 10% improve.
   but in arm64,  it have great degradation.  

  Thanks
  zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
