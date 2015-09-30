Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB886B0272
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 11:37:38 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so204607527wic.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 08:37:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fw8si1400084wjb.44.2015.09.30.08.37.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Sep 2015 08:37:37 -0700 (PDT)
Subject: Re: [PATCH 0/3] allow zram to use zbud as underlying allocator
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
 <20150915061349.GA16485@bbox>
 <CAMJBoFM_bMvQthAJPK+w4uQznqp7eFLdk=c7ZtT-R1aoF-1SeA@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <560C01BF.3040604@suse.cz>
Date: Wed, 30 Sep 2015 17:37:35 +0200
MIME-Version: 1.0
In-Reply-To: <CAMJBoFM_bMvQthAJPK+w4uQznqp7eFLdk=c7ZtT-R1aoF-1SeA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>, Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, =?UTF-8?B?6rmA7KSA7IiY?= <iamjoonsoo.kim@lge.com>, Gioh Kim <gioh.kim@lge.com>

On 09/25/2015 11:54 AM, Vitaly Wool wrote:
> Hello Minchan,
>
> the main use case where I see unacceptably long stalls in UI with
> zsmalloc is switching between users in Android.
> There is a way to automate user creation and switching between them so
> the test I run both to get vmstat statistics and to profile stalls is
> to create a user, switch to it and switch back. Each test cycle does
> that 10 times, and all the results presented below are averages for 20
> runs.
>
> Kernel configurations used for testing:
>
> (1): vanilla
> (2): (1) plus "make SLUB atomic" patch [1]
> (3): (1) with zbud instead of zsmalloc
> (4): (2) with compaction defer logic mostly disabled

Disabling compaction deferring leads to less compaction stalls? That 
indeed looks very weird and counter-intuitive. Also what's "mostly" 
disabled mean?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
