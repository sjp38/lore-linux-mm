Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 45F224403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 12:02:09 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id xk3so70264381obc.2
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 09:02:09 -0800 (PST)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id mr2si790344obb.80.2016.02.04.09.02.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 09:02:08 -0800 (PST)
Received: by mail-oi0-x232.google.com with SMTP id s2so19497098oie.2
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 09:02:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160204165744.GG14425@dhcp22.suse.cz>
References: <56b29d2d.92SImyffndn0eAz+%akpm@linux-foundation.org>
	<20160204165744.GG14425@dhcp22.suse.cz>
Date: Fri, 5 Feb 2016 02:02:08 +0900
Message-ID: <CAAmzW4OPM_+tgxxPpyb0y=qro68+MY1bio=UT+P1O_B4JKe2Yg@mail.gmail.com>
Subject: Re: mmotm 2016-02-03-16-36 uploaded
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, mm-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, broonie@kernel.org, Minchan Kim <minchan@kernel.org>

2016-02-05 1:57 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> [CCing Minchan]
>
> I am getting many compilation errors if !CONFIG_COMPACTION and
> CONFIG_MEMORY_ISOLATION=y. I didn't get to check what has hanged in that
> regards because this code is quite old but the previous mmotm seemed ok,
> maybe some subtle change in my config?

It would be caused by Vlastimil's "mm, hugetlb: don't require CMA for
runtime gigantic pages".

https://lkml.org/lkml/2016/2/3/841

Fix is already there.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
