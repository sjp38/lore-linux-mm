Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC0F86B0007
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 07:10:49 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u65so5216586pfd.7
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 04:10:49 -0800 (PST)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00115.outbound.protection.outlook.com. [40.107.0.115])
        by mx.google.com with ESMTPS id c10si3930966pgq.535.2018.03.02.04.10.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 02 Mar 2018 04:10:48 -0800 (PST)
Subject: Re: [PATCH 1/2] kasan: fix invalid-free test crashing the kernel
References: <cover.1519924383.git.andreyknvl@google.com>
 <286eaefc0a6c3fa9b83b87e7d6dc0fbb5b5c9926.1519924383.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <818fe418-01cd-4664-9844-46455b06842d@virtuozzo.com>
Date: Fri, 2 Mar 2018 15:11:21 +0300
MIME-Version: 1.0
In-Reply-To: <286eaefc0a6c3fa9b83b87e7d6dc0fbb5b5c9926.1519924383.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Nick Terrell <terrelln@fb.com>, Chris Mason <clm@fb.com>, Yury Norov <ynorov@caviumnetworks.com>, Al Viro <viro@zeniv.linux.org.uk>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Palmer Dabbelt <palmer@dabbelt.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Jeff Layton <jlayton@redhat.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Cc: Kostya Serebryany <kcc@google.com>



On 03/01/2018 08:15 PM, Andrey Konovalov wrote:
> When an invalid-free is triggered by one of the KASAN tests, the object
> doesn't actually get freed. This later leads to a BUG failure in
> kmem_cache_destroy that checks that there are no allocated objects in the
> cache that is being destroyed. Fix this by calling kmem_cache_free with
> the proper object address after the call that triggers invalid-free.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
