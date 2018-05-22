Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 54B4F6B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 12:25:33 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id y127-v6so19946215qka.5
        for <linux-mm@kvack.org>; Tue, 22 May 2018 09:25:33 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50130.outbound.protection.outlook.com. [40.107.5.130])
        by mx.google.com with ESMTPS id y26-v6si2701928qvc.249.2018.05.22.09.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 May 2018 09:25:32 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] kasan: free allocated shadow memory on
 MEM_CANCEL_ONLINE
References: <20180522100756.18478-1-david@redhat.com>
 <20180522100756.18478-2-david@redhat.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <6666c564-916d-a145-183c-362e6f72c409@virtuozzo.com>
Date: Tue, 22 May 2018 19:26:43 +0300
MIME-Version: 1.0
In-Reply-To: <20180522100756.18478-2-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, "open list:KASAN" <kasan-dev@googlegroups.com>



On 05/22/2018 01:07 PM, David Hildenbrand wrote:
> We have to free memory again when we cancel onlining, otherwise a later
> onlining attempt will fail.
> 
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---

Fixes: fa69b5989bb0 ("mm/kasan: add support for memory hotplug")
Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: <stable@vger.kernel.org>

>  mm/kasan/kasan.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 135ce2838c89..53564229674b 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -867,6 +867,7 @@ static int __meminit kasan_mem_notifier(struct notifier_block *nb,
>  		kmemleak_ignore(ret);
>  		return NOTIFY_OK;
>  	}
> +	case MEM_CANCEL_ONLINE:
>  	case MEM_OFFLINE: {
>  		struct vm_struct *vm;
>  
> 
