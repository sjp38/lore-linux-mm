Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 47B866B039F
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 09:31:51 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id c72so14635510ita.13
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 06:31:51 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50101.outbound.protection.outlook.com. [40.107.5.101])
        by mx.google.com with ESMTPS id b4si7917647iog.130.2017.03.29.06.31.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 06:31:50 -0700 (PDT)
Subject: Re: [PATCH v4 0/9] kasan: improve error reports
References: <cover.1490383597.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <a862e2c1-fc55-746f-de40-9b392df2610e@virtuozzo.com>
Date: Wed, 29 Mar 2017 16:33:09 +0300
MIME-Version: 1.0
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/24/2017 10:32 PM, Andrey Konovalov wrote:

> 
> Andrey Konovalov (9):
>   kasan: introduce helper functions for determining bug type
>   kasan: unify report headers
>   kasan: change allocation and freeing stack traces headers
>   kasan: simplify address description logic
>   kasan: change report header
>   kasan: improve slab object description
>   kasan: print page description after stacks
>   kasan: improve double-free report format
>   kasan: separate report parts by empty lines
> 
>  include/linux/kasan.h |   2 +-
>  mm/kasan/kasan.c      |   5 +-
>  mm/kasan/kasan.h      |   2 +-
>  mm/kasan/report.c     | 172 +++++++++++++++++++++++++++++++-------------------
>  mm/slab.c             |   2 +-
>  mm/slub.c             |  12 ++--
>  6 files changed, 121 insertions(+), 74 deletions(-)
> 

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
