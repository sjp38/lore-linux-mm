Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1236B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 19:04:22 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id b17so8698904lan.22
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 16:04:22 -0700 (PDT)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id pw10si6564392lbb.119.2014.09.02.16.04.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 16:04:21 -0700 (PDT)
Received: by mail-lb0-f178.google.com with SMTP id v6so8469419lbi.37
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 16:04:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140902171036.GA12406@kria>
References: <1408892163-8073-1-git-send-email-akinobu.mita@gmail.com>
	<1408892163-8073-2-git-send-email-akinobu.mita@gmail.com>
	<20140902171036.GA12406@kria>
Date: Wed, 3 Sep 2014 08:04:20 +0900
Message-ID: <CAC5umygz-bsrWJErmyaLE25cXCpXHpw5uiKeM7-pD+KvKtjmxw@mail.gmail.com>
Subject: Re: kmemleak: Cannot insert [...] into the object search tree
 (overlaps existing) (mm: use memblock_alloc_range())
From: Akinobu Mita <akinobu.mita@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

2014-09-03 2:10 GMT+09:00 Sabrina Dubroca <sd@queasysnail.net>:
> Hello,
>
> 2014-08-24, 23:56:03 +0900, Akinobu Mita wrote:
>> Replace memblock_find_in_range() and memblock_reserve() with
>> memblock_alloc_range().
>>
>> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
>> Cc: linux-mm@kvack.org
>
> This patch is included in linux-next, and when I boot next-20140901,
> on a 32-bit build, I get this message:
>
>
> kmemleak: Cannot insert 0xf6556000 into the object search tree (overlaps existing)

kmemleak_alloc() in memblock_virt_alloc_internal() should have been removed by
the conversion in this patch.  Otherwise kmemleak() is called twice because
memblock_alloc_range() also calls it.

Andrew, could you drop this patch for now.  I'll send the patch with this fix.

Thanks for the report.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
