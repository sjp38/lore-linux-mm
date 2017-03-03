Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 505B36B039C
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 08:36:18 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id p41so3168824otb.4
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 05:36:18 -0800 (PST)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30102.outbound.protection.outlook.com. [40.107.3.102])
        by mx.google.com with ESMTPS id f125si4744668oia.267.2017.03.03.05.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 03 Mar 2017 05:36:17 -0800 (PST)
Subject: Re: [PATCH v2 4/9] kasan: simplify address description logic
References: <20170302134851.101218-1-andreyknvl@google.com>
 <20170302134851.101218-5-andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <af173ed6-705c-057d-e713-be89c80be582@virtuozzo.com>
Date: Fri, 3 Mar 2017 16:37:23 +0300
MIME-Version: 1.0
In-Reply-To: <20170302134851.101218-5-andreyknvl@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 03/02/2017 04:48 PM, Andrey Konovalov wrote:

> -static void kasan_object_err(struct kmem_cache *cache, void *object)
> +static struct page *addr_to_page(const void *addr)
> +{
> +	if ((addr >= (void *)PAGE_OFFSET) &&
> +			(addr < high_memory))

Should fit in one line.

> +		return virt_to_head_page(addr);
> +	return NULL;
> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
