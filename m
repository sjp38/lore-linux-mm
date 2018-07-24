Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7C9416B0006
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 18:38:41 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a70-v6so4816919qkb.16
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 15:38:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m63-v6sor6131176qkd.12.2018.07.24.15.38.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 15:38:40 -0700 (PDT)
Subject: Re: freepage accounting bug with CMA/migrate isolation
References: <86bea4f7-229a-7cbb-1e8a-7e6d96f0f087@oracle.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <92636e32-c71b-0092-02bf-a802065075ef@redhat.com>
Date: Tue, 24 Jul 2018 15:38:37 -0700
MIME-Version: 1.0
In-Reply-To: <86bea4f7-229a-7cbb-1e8a-7e6d96f0f087@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>

On 07/23/2018 09:24 PM, Mike Kravetz wrote:
> With v4.17, I can see an issue like those addressed in commits 3c605096d315
> ("mm/page_alloc: restrict max order of merging on isolated pageblock")
> and d9dddbf55667 ("mm/page_alloc: prevent merging between isolated and
> other pageblocks").  After running a CMA stress test for a while, I see:
>    MemTotal:        8168384 kB
>    MemFree:         8457232 kB
>    MemAvailable:    9204844 kB
> If I let the test run, MemFree and MemAvailable will continue to grow.
> 
> I am certain the issue is with pageblocks of migratetype ISOLATED.  If
> I disable all special 'is_migrate_isolate' checks in freepage accounting,
> the issue goes away.  Further, I am pretty sure the issue has to do with
> pageblock merging and or page orders spanning pageblocks.  If I make
> pageblock_order equal MAX_ORDER-1, the issue also goes away.
> 
> Just looking for suggesting in where/how to debug.  I've been hacking on
> this without much success.
> --
> Mike Kravetz
> 

If you revert d883c6cf3b39 ("Revert "mm/cma: manage the memory of the CMA
area by using the ZONE_MOVABLE"") do you still see the issue? I thought
there was another isolation edge case which was fixed by that series.

Thanks,
Laura
