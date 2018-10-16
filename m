Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 96CCD6B0003
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 10:17:16 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i16-v6so14044008ede.11
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 07:17:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c2-v6sor10190934edb.29.2018.10.16.07.17.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Oct 2018 07:17:15 -0700 (PDT)
Date: Tue, 16 Oct 2018 14:17:13 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC PATCH] mm: add a vma to vmacache when addr overlaps the vma
 range
Message-ID: <20181016141713.qtry7cvtap6wzmj4@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181016134712.18123-1-richard.weiyang@gmail.com>
 <20181016135404.GA13818@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181016135404.GA13818@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, linux-mm@kvack.org

On Tue, Oct 16, 2018 at 06:54:04AM -0700, Matthew Wilcox wrote:
>On Tue, Oct 16, 2018 at 09:47:12PM +0800, Wei Yang wrote:
>> Based on my understanding, this change would put more accurate vma entry in the
>> cache, which means reduce unnecessary vmacache update and vmacache find.
>> 
>> But the test result is not as expected. From the original changelog, I don't
>> see the explanation to add this non-overlap entry into the vmacache, so
>> curious about why this performs a little better than putting an overlapped
>> entry.
>
>What makes you think this performs any differently for this test-case?
>The numbers all seem to fall within a "reasonable variation" range to me.
>You're going to need to do some statistics (with a much larger sample
>size) to know whether there's any difference at all.
>

Matthew,

Thanks for your comment.

I use this test-case because I have little experience in performance
test and I see the original author lists the hit-rate improvement in
kernel build test.

I am thinking to evaluate the cache hit-rate, while I don't know how to
gather the statistic.

If you could give me some hint on the statistics gathering or a more
proper test case, I would appreciate a lot.

BTW, I don't get your point on "a much larger sample size". To map a
larger memory area? I lost at this point.

-- 
Wei Yang
Help you, Help me
