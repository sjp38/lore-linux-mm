Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C4D6828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 03:39:49 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id k78so456583558ioi.2
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 00:39:49 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50137.outbound.protection.outlook.com. [40.107.5.137])
        by mx.google.com with ESMTPS id e3si2522582itb.9.2016.07.06.00.39.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Jul 2016 00:39:48 -0700 (PDT)
Subject: Re: [PATCH v5] kasan/quarantine: fix bugs on qlist_move_cache()
References: <1467766348-22419-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <577CB5FD.8050709@virtuozzo.com>
Date: Wed, 6 Jul 2016 10:40:45 +0300
MIME-Version: 1.0
In-Reply-To: <1467766348-22419-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, Kuthonuzo Luruo <poll.stdin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>



On 07/06/2016 03:52 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> There are two bugs on qlist_move_cache(). One is that qlist's tail
> isn't set properly. curr->next can be NULL since it is singly linked
> list and NULL value on tail is invalid if there is one item on qlist.
> Another one is that if cache is matched, qlist_put() is called and
> it will set curr->next to NULL. It would cause to stop the loop
> prematurely.
> 
> These problems come from complicated implementation so I'd like to
> re-implement it completely. Implementation in this patch is really
> simple. Iterate all qlist_nodes and put them to appropriate list.
> 
> Unfortunately, I got this bug sometime ago and lose oops message.
> But, the bug looks trivial and no need to attach oops.
> 
> v5: rename some variable for better readability
> v4: fix cache size bug s/cache->size/obj_cache->size/
> v3: fix build warning
> 
> Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Fixes: 55834c59098d ("mm: kasan: initial memory quarantine implementation")
Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
