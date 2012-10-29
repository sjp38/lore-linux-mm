Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 2E71A6B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 09:15:57 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so5902858oag.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 06:15:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121029021219.GK15767@bbox>
References: <1351451576-2611-1-git-send-email-js1304@gmail.com>
	<20121029021219.GK15767@bbox>
Date: Mon, 29 Oct 2012 22:15:56 +0900
Message-ID: <CAAmzW4OboOMD+yrAim4-H_LBC439iYat=gwfxcn5M1gvcRyz=w@mail.gmail.com>
Subject: Re: [PATCH 0/5] minor clean-up and optimize highmem related code
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

Hi, Minchan.

2012/10/29 Minchan Kim <minchan@kernel.org>:
> Hi Joonsoo,
>
> On Mon, Oct 29, 2012 at 04:12:51AM +0900, Joonsoo Kim wrote:
>> This patchset clean-up and optimize highmem related code.
>>
>> [1] is just clean-up and doesn't introduce any functional change.
>> [2-3] are for clean-up and optimization.
>> These eliminate an useless lock opearation and list management.
>> [4-5] is for optimization related to flush_all_zero_pkmaps().
>>
>> Joonsoo Kim (5):
>>   mm, highmem: use PKMAP_NR() to calculate an index of pkmap
>>   mm, highmem: remove useless pool_lock
>>   mm, highmem: remove page_address_pool list
>>   mm, highmem: makes flush_all_zero_pkmaps() return index of last
>>     flushed entry
>>   mm, highmem: get virtual address of the page using PKMAP_ADDR()
>
> This patchset looks awesome to me.
> If you have a plan to respin, please CCed Peter.

Thanks for review.
I will wait more review and respin, the day after tomorrow.
Version 2 will include fix about your comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
