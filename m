Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 496886B0038
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 10:28:58 -0500 (EST)
Received: by iodd200 with SMTP id d200so4273705iod.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 07:28:58 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id g27si5335298ioj.149.2015.11.10.07.28.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 10 Nov 2015 07:28:57 -0800 (PST)
Date: Tue, 10 Nov 2015 09:28:56 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] tools/vm/slabinfo: update struct slabinfo members'
 types
In-Reply-To: <1447162326-30626-4-git-send-email-sergey.senozhatsky@gmail.com>
Message-ID: <alpine.DEB.2.20.1511100928440.8480@east.gentwo.org>
References: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com> <1447162326-30626-4-git-send-email-sergey.senozhatsky@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Tue, 10 Nov 2015, Sergey Senozhatsky wrote:

> Align some of `struct slabinfo' members' types with
> `struct kmem_cache' to suppress gcc warnings:

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
