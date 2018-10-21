Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D284A6B0005
	for <linux-mm@kvack.org>; Sat, 20 Oct 2018 22:36:40 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b34-v6so22615749ede.5
        for <linux-mm@kvack.org>; Sat, 20 Oct 2018 19:36:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b25-v6sor525250ejo.11.2018.10.20.19.36.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Oct 2018 19:36:39 -0700 (PDT)
Date: Sun, 21 Oct 2018 02:36:37 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC] put page to pcp->lists[] tail if it is not on the same node
Message-ID: <20181021023637.v6d3jjo65hc3nn7t@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181019043303.s5axhjfb2v2lzsr3@master>
 <20181019083818.GQ5819@techsingularity.net>
 <20181020163318.72oqszgdtqfafycu@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181020163318.72oqszgdtqfafycu@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, willy@infradead.org, mhocko@suse.com, linux-mm@kvack.org, akpm@linux-foundation.org

On Sat, Oct 20, 2018 at 04:33:18PM +0000, Wei Yang wrote:
>>
>>I suspect it would eventually cause a crash or at least weirdness as the
>>page zone ids would not match due to different nodes.
>>
>
>If my analysis is correct, there are only two relationship between page
>node_id of those pages in pcp and the pcp's node_id, either the same or
>not.
>
>Let me have a try with qemu emulated numa system. :-)
>

Just run an emulated sytem with 4 numa nodes in qemu, the kernel with
this change looks good.

But nothing to be happy, just want you be informed.

-- 
Wei Yang
Help you, Help me
