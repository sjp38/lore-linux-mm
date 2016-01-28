Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 34D6A6B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 02:40:52 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id mw1so6951086igb.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 23:40:52 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id xh1si2762196igb.81.2016.01.27.23.40.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 23:40:51 -0800 (PST)
Date: Thu, 28 Jan 2016 16:40:51 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v1 5/8] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
Message-ID: <20160128074051.GA15426@js1304-P5Q-DELUXE>
References: <cover.1453918525.git.glider@google.com>
 <a6491b8dfc46299797e67436cc1541370e9439c9.1453918525.git.glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a6491b8dfc46299797e67436cc1541370e9439c9.1453918525.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

On Wed, Jan 27, 2016 at 07:25:10PM +0100, Alexander Potapenko wrote:
> Stack depot will allow KASAN store allocation/deallocation stack traces
> for memory chunks. The stack traces are stored in a hash table and
> referenced by handles which reside in the kasan_alloc_meta and
> kasan_free_meta structures in the allocated memory chunks.

Looks really nice!

Could it be more generalized to be used by other feature that need to
store stack trace such as tracepoint or page owner?

If it could be, there is one more requirement.
I understand the fact that entry is never removed from depot makes things
very simpler, but, for general usecases, it's better to use reference count
and allow to remove. Is it possible?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
