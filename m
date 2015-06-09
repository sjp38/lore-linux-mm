Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7783B6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 17:25:25 -0400 (EDT)
Received: by payr10 with SMTP id r10so20739326pay.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 14:25:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p8si10509569pdi.112.2015.06.09.14.25.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 14:25:24 -0700 (PDT)
Date: Tue, 9 Jun 2015 14:25:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH 0/5] do not dereference NULL pools in pools'
 destroy() functions
Message-Id: <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org>
In-Reply-To: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com, Joe Perches <joe@perches.com>

On Tue,  9 Jun 2015 21:04:48 +0900 Sergey Senozhatsky <sergey.senozhatsky@gmail.com> wrote:

> The existing pools' destroy() functions do not allow NULL pool pointers;
> instead, every destructor() caller forced to check if pool is not NULL,
> which:
>  a) requires additional attention from developers/reviewers
>  b) may lead to a NULL pointer dereferences if (a) didn't work
> 
> 
> First 3 patches tweak
> - kmem_cache_destroy()
> - mempool_destroy()
> - dma_pool_destroy()
> 
> to handle NULL pointers.

Well I like it, even though it's going to cause a zillion little cleanup
patches.

checkpatch already has a "kfree(NULL) is safe and this check is
probably not required" test so I guess Joe will need to get busy ;)

I'll park these patches until after 4.1 is released - it's getting to
that time...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
