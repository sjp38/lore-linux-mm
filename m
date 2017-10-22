Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3DBCC6B0038
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 02:40:19 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id z12so13759104qkb.12
        for <linux-mm@kvack.org>; Sat, 21 Oct 2017 23:40:19 -0700 (PDT)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id 8si2906873qto.443.2017.10.21.23.40.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Oct 2017 23:40:18 -0700 (PDT)
Subject: Re: [PATCH 1/2] slab, slub, slob: add slab_flags_t
References: <20171021100225.GA22428@avx2>
From: Pekka Enberg <penberg@iki.fi>
Message-ID: <f4a10428-c35c-d1d4-1816-5175f88b8962@iki.fi>
Date: Sun, 22 Oct 2017 09:40:14 +0300
MIME-Version: 1.0
In-Reply-To: <20171021100225.GA22428@avx2>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, ecryptfs@vger.kernel.org, linux-xfs@vger.kernel.org, kasan-dev@googlegroups.com, netdev@vger.kernel.org



On 21/10/2017 13.02, Alexey Dobriyan wrote:
> Add sparse-checked slab_flags_t for struct kmem_cache::flags
> (SLAB_POISON, etc).
> 
> SLAB is bloated temporarily by switching to "unsigned long",
> but only temporarily.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Acked-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
