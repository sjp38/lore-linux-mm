Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 88804440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 15:57:49 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id v193so29795815itc.10
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 12:57:49 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id h187si3280744ite.47.2017.07.12.12.57.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 12:57:48 -0700 (PDT)
Date: Wed, 12 Jul 2017 14:57:47 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: make sure struct kmem_cache_node is initialized
 before publication
In-Reply-To: <20170712122154.f6bafdc86ccfd189fefbb0a3@linux-foundation.org>
Message-ID: <alpine.DEB.2.20.1707121456320.16986@nuc-kabylake>
References: <20170707083408.40410-1-glider@google.com> <20170707132351.4f10cd778fc5eb58e9cc5513@linux-foundation.org> <alpine.DEB.2.20.1707071816560.20454@east.gentwo.org> <20170710133238.2afcda57ea28e020ca03c4f0@linux-foundation.org>
 <CAG_fn=WKtQhGfcTxvRgDYnAkOp1acGUmnLyoJRf6syvEL-Yysg@mail.gmail.com> <20170712122154.f6bafdc86ccfd189fefbb0a3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, Dmitriy Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, 12 Jul 2017, Andrew Morton wrote:

> - free_kmem_cache_nodes() frees the cache node before nulling out a
>   reference to it
>
> - init_kmem_cache_nodes() publishes the cache node before initializing it
>
> Neither of these matter at runtime because the cache nodes cannot be
> looked up by any other thread.  But it's neater and more consistent to
> reorder these.

The compiler or processor may reorder them at will anyways. But if its
tidier....

Acked-by: Christoph Lameter <cl@linux.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
