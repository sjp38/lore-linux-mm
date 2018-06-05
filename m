Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB7F6B0007
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 13:04:19 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id b8-v6so3021175qto.13
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 10:04:19 -0700 (PDT)
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id 18-v6si3749526qku.348.2018.06.05.10.04.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Jun 2018 10:04:18 -0700 (PDT)
Date: Tue, 5 Jun 2018 17:04:17 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: Clean up the code comment in slab kmem_cache
 struct
In-Reply-To: <20180603032402.27526-1-bhe@redhat.com>
Message-ID: <01000163d0e8083c-096b06d6-7202-4ce2-b41c-0f33784afcda-000000@email.amazonses.com>
References: <20180603032402.27526-1-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org

On Sun, 3 Jun 2018, Baoquan He wrote:

> diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
> index d9228e4d0320..3485c58cfd1c 100644
> --- a/include/linux/slab_def.h
> +++ b/include/linux/slab_def.h
> @@ -67,9 +67,10 @@ struct kmem_cache {
>
>  	/*
>  	 * If debugging is enabled, then the allocator can add additional
> -	 * fields and/or padding to every object. size contains the total
> -	 * object size including these internal fields, the following two
> -	 * variables contain the offset to the user object and its size.
> +	 * fields and/or padding to every object. 'size' contains the total
> +	 * object size including these internal fields, while 'obj_offset'
> +	 * and 'object_size' contain the offset to the user object and its
> +	 * size.
>  	 */
>  	int obj_offset;
>  #endif /* CONFIG_DEBUG_SLAB */
>

Wish we had some more consistent naming. object_size and obj_offset??? And
the fields better be as close together as possible.


Acked-by: Christoph Lameter <cl@linux.com>
