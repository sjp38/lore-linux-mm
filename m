Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id CBCD16B0275
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 11:46:27 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so201401541wic.1
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 08:46:27 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id lb9si1384165wjb.188.2015.09.30.08.46.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 08:46:26 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so205013906wic.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 08:46:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <560C01BF.3040604@suse.cz>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
	<20150915061349.GA16485@bbox>
	<CAMJBoFM_bMvQthAJPK+w4uQznqp7eFLdk=c7ZtT-R1aoF-1SeA@mail.gmail.com>
	<560C01BF.3040604@suse.cz>
Date: Wed, 30 Sep 2015 17:46:26 +0200
Message-ID: <CAMJBoFNpqrr_5iuQ68TrRPP=Uv0SYPra6XH27NAcG+Apq=CoSg@mail.gmail.com>
Subject: Re: [PATCH 0/3] allow zram to use zbud as underlying allocator
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, =?UTF-8?B?6rmA7KSA7IiY?= <iamjoonsoo.kim@lge.com>, Gioh Kim <gioh.kim@lge.com>

On Wed, Sep 30, 2015 at 5:37 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 09/25/2015 11:54 AM, Vitaly Wool wrote:
>>
>> Hello Minchan,
>>
>> the main use case where I see unacceptably long stalls in UI with
>> zsmalloc is switching between users in Android.
>> There is a way to automate user creation and switching between them so
>> the test I run both to get vmstat statistics and to profile stalls is
>> to create a user, switch to it and switch back. Each test cycle does
>> that 10 times, and all the results presented below are averages for 20
>> runs.
>>
>> Kernel configurations used for testing:
>>
>> (1): vanilla
>> (2): (1) plus "make SLUB atomic" patch [1]
>> (3): (1) with zbud instead of zsmalloc
>> (4): (2) with compaction defer logic mostly disabled
>
>
> Disabling compaction deferring leads to less compaction stalls? That inde=
ed
> looks very weird and counter-intuitive. Also what's "mostly" disabled mea=
n?

Not that I'm not surprised myself. However, this is how it goes.
Namely, I reverted the following patches:
- mm, compaction: defer each zone individually instead of preferred zone
- mm, compaction: embed migration mode in compact_control
- mm, compaction: add per-zone migration pfn cache for async compaction
- =EF=BF=BCmm: compaction: encapsulate defer reset logic

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
