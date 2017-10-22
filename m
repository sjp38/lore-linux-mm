Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E423C6B0253
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 02:40:30 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id k31so13040084qta.22
        for <linux-mm@kvack.org>; Sat, 21 Oct 2017 23:40:30 -0700 (PDT)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id n3si3775384qkb.427.2017.10.21.23.40.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Oct 2017 23:40:30 -0700 (PDT)
Subject: Re: [PATCH 2/2] slab, slub, slob: convert slab_flags_t to 32-bit
References: <20171021100225.GA22428@avx2> <20171021100635.GA8287@avx2>
From: Pekka Enberg <penberg@iki.fi>
Message-ID: <ed694fcb-c1b8-849f-dc5d-145aa8872ad2@iki.fi>
Date: Sun, 22 Oct 2017 09:40:27 +0300
MIME-Version: 1.0
In-Reply-To: <20171021100635.GA8287@avx2>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, ecryptfs@vger.kernel.org, linux-xfs@vger.kernel.org, kasan-dev@googlegroups.com, netdev@vger.kernel.org



On 21/10/2017 13.06, Alexey Dobriyan wrote:
> struct kmem_cache::flags is "unsigned long" which is unnecessary on
> 64-bit as no flags are defined in the higher bits.
> 
> Switch the field to 32-bit and save some space on x86_64 until such
> flags appear:
> 
> 	add/remove: 0/0 grow/shrink: 0/107 up/down: 0/-657 (-657)
> 	function                                     old     new   delta
> 	sysfs_slab_add                               720     719      -1
> 				...
> 	check_object                                 699     676     -23
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Acked-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
