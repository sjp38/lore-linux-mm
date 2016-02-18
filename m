Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id B414B828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 12:32:43 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id xg9so17487239igb.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:32:43 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id on1si6537016igb.65.2016.02.18.09.32.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Feb 2016 09:32:41 -0800 (PST)
Date: Thu, 18 Feb 2016 11:32:40 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 0/7] SLAB support for KASAN
In-Reply-To: <cover.1455811491.git.glider@google.com>
Message-ID: <alpine.DEB.2.20.1602181131320.24647@east.gentwo.org>
References: <cover.1455811491.git.glider@google.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 18 Feb 2016, Alexander Potapenko wrote:

> Unlike SLUB, SLAB doesn't store allocation/deallocation stacks for heap
> objects, therefore we reimplement this feature in mm/kasan/stackdepot.c.
> The intention is to ultimately switch SLUB to use this implementation as
> well, which will remove the dependency on SLUB_DEBUG.

This needs to be clarified a bit. CONFIG_SLUB_DEBUG is on by default. So
the dependency does not matter much. I think you depend on the slowpath
debug processing right? The issue is that you want to do these things in
the fastpath?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
