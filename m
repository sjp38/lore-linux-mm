Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id D165A6B0038
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 04:18:24 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so49675018wic.1
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 01:18:24 -0700 (PDT)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id hv7si34824906wjb.43.2015.09.30.01.18.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 01:18:23 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so49601468wic.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 01:18:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150930081304.GE12727@bbox>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
	<20150915061349.GA16485@bbox>
	<CAMJBoFM_bMvQthAJPK+w4uQznqp7eFLdk=c7ZtT-R1aoF-1SeA@mail.gmail.com>
	<20150930075203.GC12727@bbox>
	<CAMJBoFN3j5eZh4+4dnJya9=8Jo=3O9u+v7g0Ka+aVaQyMOG2ew@mail.gmail.com>
	<20150930081304.GE12727@bbox>
Date: Wed, 30 Sep 2015 10:18:23 +0200
Message-ID: <CAMJBoFNNQRe3gAHXLvnOG_bZ4fxKTUYy7D27n6VyhjQstJXdgA@mail.gmail.com>
Subject: Re: [PATCH 0/3] allow zram to use zbud as underlying allocator
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, =?UTF-8?B?6rmA7KSA7IiY?= <iamjoonsoo.kim@lge.com>, Gioh Kim <gioh.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Sep 30, 2015 at 10:13 AM, Minchan Kim <minchan@kernel.org> wrote:
> On Wed, Sep 30, 2015 at 10:01:59AM +0200, Vitaly Wool wrote:
>> > Could you share your script?
>> > I will ask our production team to reproduce it.
>>
>> Wait, let me get it right. Your production team?
>> I take it as you would like me to help your company fix your bugs.
>> You are pushing the limits here.
>
> I'm really sorry if you take it as fixing my bugs.
> I never wanted it but just want to help your problem.
> Please read LKML. Normally, developers wanted to share test script to
> reproduce the problem because it's easier to solve the problem
> without consuming much time with ping-pong.

Normally developers do not have backing up "production teams".

> Anyway, I have shared my experience to you and suggest patches and
> on-going works. In your concept, I shouldn't do that for fixing
> your problems so I shouldn't help you any more? Right?

I never asked you to fix my problems. I have substantial proof that
zsmalloc is fragile enough not to be a good fit for projects I work on
and I want to have the code that allows zram to work with zbud
mainlined. Whatever you want me to do to help you fix zsmalloc issues
*should* be *orthogonal* to the former. You are abusing your
maintainer role here, trying to act in favor of your company rather
than for the benefit of OSS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
