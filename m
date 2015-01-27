Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 361A06B006E
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 20:42:57 -0500 (EST)
Received: by mail-oi0-f50.google.com with SMTP id h136so10218462oig.9
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 17:42:57 -0800 (PST)
Received: from mail-ob0-x229.google.com (mail-ob0-x229.google.com. [2607:f8b0:4003:c01::229])
        by mx.google.com with ESMTPS id c1si2609639obw.107.2015.01.26.17.42.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 17:42:56 -0800 (PST)
Received: by mail-ob0-f169.google.com with SMTP id va8so11124878obc.0
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 17:42:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150126154506.GA528@blaptop>
References: <1422107153-9701-1-git-send-email-opensource.ganesh@gmail.com>
	<20150126154506.GA528@blaptop>
Date: Tue, 27 Jan 2015 09:42:55 +0800
Message-ID: <CADAEsF8MvAWp20KCZp2Z2MSF3fXah-1+ehxsH0wBRQnzJRZ3Vg@mail.gmail.com>
Subject: Re: [PATCH] zram: free meta table in zram_meta_free
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Hello, Minchan

2015-01-26 23:45 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> Hello,
>
> On Sat, Jan 24, 2015 at 09:45:53PM +0800, Ganesh Mahendran wrote:
>> zram_meta_alloc() and zram_meta_free() are a pair.
>> In zram_meta_alloc(), meta table is allocated. So it it better to free
>> it in zram_meta_free().
>>
>> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
>> Cc: Nitin Gupta <ngupta@vflare.org>
>> Cc: Minchan Kim <minchan@kernel.org>
>
> Looks good to me but it seems the patch is based on my recent work
> "zram: free meta out of init_lock".
> Please resend it on recent mmotm because I will respin my patch and
> your patch is orthogonal with mine.

OK, I will resend the patch. Thanks.

>
> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
