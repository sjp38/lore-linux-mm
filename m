Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 121406B039F
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 11:10:53 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id x86so16599287ioe.5
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 08:10:53 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id m4si18129743wmb.0.2017.04.10.08.10.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 08:10:52 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id AFD22992E0
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 15:10:51 +0000 (UTC)
Date: Mon, 10 Apr 2017 16:10:51 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: Page allocator order-0 optimizations merged
Message-ID: <20170410151051.n4lytmha4tqh4l3t@techsingularity.net>
References: <58b48b1f.F/jo2/WiSxvvGm/z%akpm@linux-foundation.org>
 <20170301144845.783f8cad@redhat.com>
 <58EB9754.3090202@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <58EB9754.3090202@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>, Tariq Toukan <tariqt@mellanox.com>

On Mon, Apr 10, 2017 at 10:31:48PM +0800, zhong jiang wrote:
> Hi, Mel
> 
>      The patch I had test on arm64. I find the great degradation. I test it by micro-bench.
>     The patrly data is as following.  and it is stable.  That stands for the allocate and free time. 
>     

What type of allocations is the benchmark doing? In particular, what context
is the microbenchmark allocating from? Lastly, how did you isolate the
patch, did you test two specific commits in mainline or are you comparing
4.10 with 4.11-rcX?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
