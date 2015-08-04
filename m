Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 530746B0253
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 21:15:09 -0400 (EDT)
Received: by pacgq8 with SMTP id gq8so37106724pac.3
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 18:15:09 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id o6si29443590pds.214.2015.08.03.18.15.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Aug 2015 18:15:07 -0700 (PDT)
Message-ID: <55C011A6.1090003@huawei.com>
Date: Tue, 4 Aug 2015 09:13:10 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add the block to the tail of the list in expand()
References: <55BB4027.7080200@huawei.com> <55BC0392.2070205@intel.com> <55BECC85.7050206@huawei.com> <55BEE99E.8090901@intel.com>
In-Reply-To: <55BEE99E.8090901@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, iamjoonsoo.kim@lge.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/8/3 12:10, Dave Hansen wrote:

> On 08/02/2015 07:05 PM, Xishi Qiu wrote:
>>>> Also, this might not do very much good in practice.  If you are
>>>> splitting a high-order page, you are doing the split because the
>>>> lower-order lists are empty.  So won't that list_add() be to an empty
>>
>> I made a mistake, you are right, all the lower-order lists are empty,
>> so it is no sense to add to the tail.
> 
> I actually tested this experimentally and the lists are not always
> empty.  It's probably __rmqueue_smallest() vs. __rmqueue_fallback() logic.
> 
> In any case, you might want to double-check.
> 

Hi Dave,

How did you do the experiment?

Thanks,
Xishi Qiu

> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
