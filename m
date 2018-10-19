Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DD3356B026B
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 04:38:21 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x20-v6so20027907eda.21
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 01:38:21 -0700 (PDT)
Received: from outbound-smtp25.blacknight.com (outbound-smtp25.blacknight.com. [81.17.249.193])
        by mx.google.com with ESMTPS id bo22-v6si5299066ejb.123.2018.10.19.01.38.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Oct 2018 01:38:20 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp25.blacknight.com (Postfix) with ESMTPS id 62797B89C7
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 09:38:20 +0100 (IST)
Date: Fri, 19 Oct 2018 09:38:18 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC] put page to pcp->lists[] tail if it is not on the same node
Message-ID: <20181019083818.GQ5819@techsingularity.net>
References: <20181019043303.s5axhjfb2v2lzsr3@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181019043303.s5axhjfb2v2lzsr3@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: willy@infradead.org, mhocko@suse.com, linux-mm@kvack.org, akpm@linux-foundation.org

On Fri, Oct 19, 2018 at 04:33:03AM +0000, Wei Yang wrote:
> node
> Reply-To: Wei Yang <richard.weiyang@gmail.com>
> 
> Masters,
> 
> During the code reading, I pop up this idea.
> 
>     In case we put some intelegence of NUMA node to pcp->lists[], we may
>     get a better performance.
> 

Why?

> The idea is simple:
> 
>     Put page on other nodes to the tail of pcp->lists[], because we
>     allocate from head and free from tail.
> 

Pages from remote nodes are not placed on local lists. Even in the slab
context, such objects are placed on alien caches which have special
handling.

> Since my desktop just has one numa node, I couldn't test the effect.

I suspect it would eventually cause a crash or at least weirdness as the
page zone ids would not match due to different nodes.

> Sorry for sending this without a real justification. Hope this will not
> make you uncomfortable. I would be very glad if you suggest some
> verifications that I could do.
> 
> Below is my testing patch, look forward your comments.
> 

I commend you trying to understand how the page allocator works but I
suggest you take a step back, pick a workload that is of interest and
profile it to see where hot spots are that may pinpoint where an
improvement can be made.

-- 
Mel Gorman
SUSE Labs
