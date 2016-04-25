Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D33046B025E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 03:28:50 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id s63so36661548wme.2
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 00:28:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z189si9041394wmg.33.2016.04.25.00.28.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Apr 2016 00:28:49 -0700 (PDT)
Subject: Re: [PATCH v2] z3fold: the 3-fold allocator for compressed pages
References: <5715FEFD.9010001@gmail.com>
 <20160421162210.f4a50b74bc6ce886ac8c8e4e@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571DC72F.3030503@suse.cz>
Date: Mon, 25 Apr 2016 09:28:47 +0200
MIME-Version: 1.0
In-Reply-To: <20160421162210.f4a50b74bc6ce886ac8c8e4e@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>

On 04/22/2016 01:22 AM, Andrew Morton wrote:
> On Tue, 19 Apr 2016 11:48:45 +0200 Vitaly Wool <vitalywool@gmail.com> wrote:
>
>> This patch introduces z3fold, a special purpose allocator for storing
>> compressed pages. It is designed to store up to three compressed pages per
>> physical page. It is a ZBUD derivative which allows for higher compression
>> ratio keeping the simplicity and determinism of its predecessor.
>>
>> The main differences between z3fold and zbud are:
>> * unlike zbud, z3fold allows for up to PAGE_SIZE allocations
>> * z3fold can hold up to 3 compressed pages in its page
>>
>> This patch comes as a follow-up to the discussions at the Embedded Linux
>> Conference in San-Diego related to the talk [1]. The outcome of these
>> discussions was that it would be good to have a compressed page allocator
>> as stable and deterministic as zbud with with higher compression ratio.
>>
>> To keep the determinism and simplicity, z3fold, just like zbud, always
>> stores an integral number of compressed pages per page, but it can store
>> up to 3 pages unlike zbud which can store at most 2. Therefore the
>> compression ratio goes to around 2.5x while zbud's one is around 1.7x.
>>
>> The patch is based on the latest linux.git tree.
>>
>> This version of the patch has updates related to various concurrency fixes
>> made after intensive testing on SMP/HMP platforms.
>>
>> [1]https://openiotelc2016.sched.org/event/6DAC/swapping-and-embedded-compression-relieves-the-pressure-vitaly-wool-softprise-consulting-ou
>>
>
> So...  why don't we just replace zbud with z3fold?  (Update the changelog
> to answer this rather obvious question, please!)

There was discussion between Seth and Vitaly on v1. Without me knowing 
the details myself, it looked like Seth's objections were addressed, but 
then the thread died. I think there should first be a more clear answer 
from Seth whether z3fold really looks like a clear win (i.e. not 
workload-dependent) over zbud, in which case zbud could be extended?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
