Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD10D6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 08:08:15 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id c6-v6so1772896pll.4
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 05:08:15 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50122.outbound.protection.outlook.com. [40.107.5.122])
        by mx.google.com with ESMTPS id w65-v6si2288764pfb.309.2018.06.20.05.08.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 20 Jun 2018 05:08:14 -0700 (PDT)
Subject: Re: [PATCH] slub: fix __kmem_cache_empty for !CONFIG_SLUB_DEBUG
References: <20180619213352.71740-1-shakeelb@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <3f61e143-e7b3-5517-fbaf-d663675f0e96@virtuozzo.com>
Date: Wed, 20 Jun 2018 15:09:38 +0300
MIME-Version: 1.0
In-Reply-To: <20180619213352.71740-1-shakeelb@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org



On 06/20/2018 12:33 AM, Shakeel Butt wrote:
> For !CONFIG_SLUB_DEBUG, SLUB does not maintain the number of slabs
> allocated per node for a kmem_cache. Thus, slabs_node() in
> __kmem_cache_empty() will always return 0. So, in such situation, it is
> required to check per-cpu slabs to make sure if a kmem_cache is empty or
> not.
> 
> Please note that __kmem_cache_shutdown() and __kmem_cache_shrink() are
> not affected by !CONFIG_SLUB_DEBUG as they call flush_all() to clear
> per-cpu slabs.

So what? Yes, they call flush_all() and then check if there are non-empty slabs left.
And that check doesn't work in case of disabled CONFIG_SLUB_DEBUG.
How is flush_all() or per-cpu slabs even relevant here?
