Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 17DB96B0261
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 03:32:08 -0400 (EDT)
Received: by lamp12 with SMTP id p12so100339687lam.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 00:32:07 -0700 (PDT)
Received: from mail-lb0-x234.google.com (mail-lb0-x234.google.com. [2a00:1450:4010:c04::234])
        by mx.google.com with ESMTPS id f4si12343683lah.129.2015.09.15.00.32.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 00:32:06 -0700 (PDT)
Received: by lbbvu2 with SMTP id vu2so7619197lbb.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 00:32:05 -0700 (PDT)
Subject: Re: [PATCH V3] kasan: use IS_ALIGNED in memory_is_poisoned_8()
References: <55F62C65.7070100@huawei.com>
 <CAPAsAGxf_OQD502cW1nbXJ7WdRxyKqTx6+BJJpJoD-Z6WFCZMg@mail.gmail.com>
 <55F77C52.3010101@huawei.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <55F7C976.8020901@gmail.com>
Date: Tue, 15 Sep 2015 10:32:06 +0300
MIME-Version: 1.0
In-Reply-To: <55F77C52.3010101@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <adech.fo@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, "long.wanglong" <long.wanglong@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 09/15/2015 05:02 AM, Xishi Qiu wrote:
> Use IS_ALIGNED() to determine whether the shadow span two bytes. It
> generates less code and more readable. Also add some comments in shadow
> check functions.
> 
> Please apply "kasan: fix last shadow judgement in memory_is_poisoned_16()"
> first.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
