Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 47CD34408E5
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 18:50:01 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e3so70065789pfc.4
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 15:50:01 -0700 (PDT)
Received: from mail-pg0-x230.google.com (mail-pg0-x230.google.com. [2607:f8b0:400e:c05::230])
        by mx.google.com with ESMTPS id t4si5368239plb.601.2017.07.13.15.50.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 15:50:00 -0700 (PDT)
Received: by mail-pg0-x230.google.com with SMTP id j186so36223815pge.2
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 15:50:00 -0700 (PDT)
Subject: Re: [PATCH 1/4] kasan: support alloca() poisoning
References: <20170706220114.142438-1-ghackmann@google.com>
 <20170706220114.142438-2-ghackmann@google.com>
 <66645c53-de05-8371-ead8-d4e939af60a7@virtuozzo.com>
From: Greg Hackmann <ghackmann@google.com>
Message-ID: <39dd8c5c-e606-486a-bcef-b8481c5203a1@google.com>
Date: Thu, 13 Jul 2017 15:49:58 -0700
MIME-Version: 1.0
In-Reply-To: <66645c53-de05-8371-ead8-d4e939af60a7@virtuozzo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>

On 07/10/2017 03:30 AM, Andrey Ryabinin wrote:
> gcc now supports this too. So I think this patch should enable it.
> It's off by default so you'll have to add --param asan-instrument-allocas=1 into cflags
> to make it work

Thanks, will fix.  For now, it looks like I'll need to build gcc from 
git to test this?

>>   lib/test_kasan.c  | 22 ++++++++++++++++++++++
> 
> Tests would be better as a separate patch.

I was following the precedent in 828347f8f9a5 ("kasan: support 
use-after-scope detection") which added both at the same time.  But I 
can split the test off into a separate patch if you feel really strongly 
about it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
