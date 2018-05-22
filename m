Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 591DA6B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 05:58:16 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id a125-v6so18716768qkd.4
        for <linux-mm@kvack.org>; Tue, 22 May 2018 02:58:16 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j7-v6si2840725qtn.272.2018.05.22.02.58.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 02:58:15 -0700 (PDT)
Subject: Re: [PATCH v1 1/2] kasan: free allocated shadow memory on
 MEM_CANCEL_OFFLINE
References: <20180522095515.2735-1-david@redhat.com>
 <20180522095515.2735-2-david@redhat.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <781aad97-3fe7-cf78-ad27-464254a5da27@redhat.com>
Date: Tue, 22 May 2018 11:58:13 +0200
MIME-Version: 1.0
In-Reply-To: <20180522095515.2735-2-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, "open list:KASAN" <kasan-dev@googlegroups.com>

On 22.05.2018 11:55, David Hildenbrand wrote:
> We have to free memory again when we cancel onlining, otherwise a later
> onlining attempt will fail.
> 
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  mm/kasan/kasan.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 135ce2838c89..8baefe1a674b 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -867,6 +867,7 @@ static int __meminit kasan_mem_notifier(struct notifier_block *nb,
>  		kmemleak_ignore(ret);
>  		return NOTIFY_OK;
>  	}
> +	case MEM_CANCEL_OFFLINE:

Typo, MEM_CANCEL_ONLINE

>  	case MEM_OFFLINE: {
>  		struct vm_struct *vm;
>  
> 


-- 

Thanks,

David / dhildenb
