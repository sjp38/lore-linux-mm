Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 07F3C6B026B
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 02:19:50 -0400 (EDT)
Received: by mail-ob0-f177.google.com with SMTP id m7so92764497obh.3
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 23:19:50 -0700 (PDT)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id f8si5621945obv.59.2016.03.27.23.19.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Mar 2016 23:19:49 -0700 (PDT)
Received: by mail-oi0-x234.google.com with SMTP id r187so160784891oih.3
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 23:19:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201603281456.e4kLKip8%fengguang.wu@intel.com>
References: <1459144748-13664-2-git-send-email-iamjoonsoo.kim@lge.com>
	<201603281456.e4kLKip8%fengguang.wu@intel.com>
Date: Mon, 28 Mar 2016 15:19:49 +0900
Message-ID: <CAAmzW4OW7c94fN8A=bja8z4xGiWaCupGDixeDGjnau9sDknbZA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: rename _count, field of the struct page, to _refcount
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Berg <johannes@sipsolutions.net>, "David S. Miller" <davem@davemloft.net>, Sunil Goutham <sgoutham@cavium.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-03-28 15:07 GMT+09:00 kbuild test robot <lkp@intel.com>:
> Hi Joonsoo,
>
> [auto build test ERROR on net/master]
> [also build test ERROR on v4.6-rc1 next-20160327]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

Hello, bot.

Is there any way to stop further warning if I recognize that there is a mistake?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
