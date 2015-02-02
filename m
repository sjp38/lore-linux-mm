Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 851746B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 07:09:44 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id vb8so16061754obc.11
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 04:09:44 -0800 (PST)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id tr1si4355273obb.35.2015.02.02.04.09.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 04:09:43 -0800 (PST)
Received: by mail-oi0-f47.google.com with SMTP id a141so43965369oig.6
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 04:09:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150202010904.GA6402@blaptop>
References: <1422107403-10071-1-git-send-email-opensource.ganesh@gmail.com>
	<CADAEsF_fVRNCY-mx1EoyO2KwREfz6753JKdHpHMgbJUXf2sdsQ@mail.gmail.com>
	<20150202010904.GA6402@blaptop>
Date: Mon, 2 Feb 2015 20:09:42 +0800
Message-ID: <CADAEsF_Qr4b9yakrK7iEFxasCTyCz=g_qDz-A4=WcRPP-LP7ww@mail.gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: avoid unnecessary iteration when freeing size_class
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Hello Minchan:

2015-02-02 9:09 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> Hello Ganesh,
>
> On Sat, Jan 31, 2015 at 04:59:58PM +0800, Ganesh Mahendran wrote:
>> ping.
>>
>> 2015-01-24 21:50 GMT+08:00 Ganesh Mahendran <opensource.ganesh@gmail.com>:
>> > The pool->size_class[i] is assigned with the i from (zs_size_classes - 1) to 0.
>> > So if we failed in zs_create_pool(), we only need to iterate from (zs_size_classes - 1)
>> > to i, instead of from 0 to (zs_size_classes - 1)
>>
>> No functionality has been changed. This patch just avoids some
>> necessary iteration.
>
> Sorry for the delay. Did you saw any performance problem?
> I know it would be better than old but your assumption depends on the
> implmentation of zs_create_pool so if we changes(for example,
> revert 9eec4cd if compaction works well), your patch would be void.

Yes, You are right.
Thanks so much.

> If it's not a critical, I'd like to remain it as generic and doesn't
> contaminate git-blame.
>
> Thanks.
>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
