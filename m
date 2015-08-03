Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 24FA86B0256
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 00:10:11 -0400 (EDT)
Received: by padck2 with SMTP id ck2so79378121pad.0
        for <linux-mm@kvack.org>; Sun, 02 Aug 2015 21:10:10 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ys2si10635296pbc.207.2015.08.02.21.10.09
        for <linux-mm@kvack.org>;
        Sun, 02 Aug 2015 21:10:10 -0700 (PDT)
Message-ID: <55BEE99E.8090901@intel.com>
Date: Sun, 02 Aug 2015 21:10:06 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add the block to the tail of the list in expand()
References: <55BB4027.7080200@huawei.com> <55BC0392.2070205@intel.com> <55BECC85.7050206@huawei.com>
In-Reply-To: <55BECC85.7050206@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, iamjoonsoo.kim@lge.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/02/2015 07:05 PM, Xishi Qiu wrote:
>> > Also, this might not do very much good in practice.  If you are
>> > splitting a high-order page, you are doing the split because the
>> > lower-order lists are empty.  So won't that list_add() be to an empty
> 
> I made a mistake, you are right, all the lower-order lists are empty,
> so it is no sense to add to the tail.

I actually tested this experimentally and the lists are not always
empty.  It's probably __rmqueue_smallest() vs. __rmqueue_fallback() logic.

In any case, you might want to double-check.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
