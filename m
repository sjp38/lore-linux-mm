Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6CE6B039E
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 08:30:56 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id f84so96292072ioj.6
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 05:30:56 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0097.outbound.protection.outlook.com. [104.47.1.97])
        by mx.google.com with ESMTPS id 130si2348175ith.47.2017.03.03.05.30.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 03 Mar 2017 05:30:55 -0800 (PST)
Subject: Re: [PATCH v2 6/9] kasan: improve slab object description
References: <20170302134851.101218-1-andreyknvl@google.com>
 <20170302134851.101218-7-andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <db0b6605-32bc-4c7a-0c99-2e60e4bdb11f@virtuozzo.com>
Date: Fri, 3 Mar 2017 16:31:59 +0300
MIME-Version: 1.0
In-Reply-To: <20170302134851.101218-7-andreyknvl@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/02/2017 04:48 PM, Andrey Konovalov wrote:
> Changes slab object description from:
> 
> Object at ffff880068388540, in cache kmalloc-128 size: 128
> 
> to:
> 
> The buggy address belongs to the object at ffff880068388540
>  which belongs to the cache kmalloc-128 of size 128
> The buggy address is located 123 bytes inside of
>  128-byte region [ffff880068388540, ffff8800683885c0)
> 
> Makes it more explanatory and adds information about relative offset
> of the accessed address to the start of the object.
> 

I don't think that this is an improvement. You replaced one simple line with a huge
and hard to parse text without giving any new/useful information.
Except maybe offset, it useful sometimes, so wouldn't mind adding it to description.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
