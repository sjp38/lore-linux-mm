Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB1F6B0101
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 02:02:01 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id fp1so11737387pdb.9
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 23:02:00 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id t11si22127034pdl.62.2014.11.11.23.01.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 23:01:59 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id lj1so12240677pab.22
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 23:01:59 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Date: Wed, 12 Nov 2014 16:02:43 +0900 (KST)
Subject: Re: [RFC v1 0/6] introduce gcma
In-Reply-To: <alpine.DEB.2.11.1411111255420.6657@gentwo.org>
Message-ID: <alpine.DEB.2.10.1411121549300.18607@hxeon>
References: <1415718010-18663-1-git-send-email-sj38.park@gmail.com> <alpine.DEB.2.11.1411111255420.6657@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: SeongJae Park <sj38.park@gmail.com>, akpm@linux-foundation.org, lauraa@codeaurora.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org

Hi Christoph,

On Tue, 11 Nov 2014, Christoph Lameter wrote:

> On Wed, 12 Nov 2014, SeongJae Park wrote:
>
>> Difference with cma is choice and operation of 2nd-class client. In gcma,
>> 2nd-class client should allocate pages from the reserved area only if the
>> allocated pages mets following conditions.
>
> How about making CMA configurable in some fashion to be able to specify
> the type of 2nd class clients? Clean page-cache pages can also be rather
> easily evicted (see zone-reclaim). You could migrate them out when they
> are dirtied so that you do not have the high writeback latency from the
> CMA reserved area if it needs to be evicted later.

Nice point.

Currently, gcma is integrated inside cma and user could decide a specific 
contiguous memory area to work in cma way(movable pages as 2nd class) or 
in gcma way(out-of-kernel, easy-to-discard pages as 2nd class).
It is implemented in 6th change of this RFC, "gcma: integrate gcma under 
cma interface".

In short, the 2nd-clients of cma is already configurable between 
movable pages and frontswap backend with this RFC.

And yes, cleancache will be great 2nd class client.
As described within coverletter, our 2nd class client candidates are 
frontswap and _cleancache_. But, because the gcma is still in unmatured 
sate yet, current RFC(this patchset) use only frontswap.
In future, it will be configurable.

Apologize I forgot to describe about future plan.

Thanks,
SeongJae Park

>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
