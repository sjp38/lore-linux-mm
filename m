Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4446B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 11:19:11 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id t15so62535496igr.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 08:19:11 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id u13si5798348ioi.189.2016.01.26.08.19.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 08:19:10 -0800 (PST)
Date: Tue, 26 Jan 2016 10:19:08 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 1/3] slub: Drop lock at the end of
 free_debug_processing
In-Reply-To: <1453770913-32287-2-git-send-email-labbott@fedoraproject.org>
Message-ID: <alpine.DEB.2.20.1601261018500.27338@east.gentwo.org>
References: <1453770913-32287-1-git-send-email-labbott@fedoraproject.org> <1453770913-32287-2-git-send-email-labbott@fedoraproject.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>

On Mon, 25 Jan 2016, Laura Abbott wrote:

> Currently, free_debug_processing has a comment "Keep node_lock to preserve
> integrity until the object is actually freed". In actuallity,
> the lock is dropped immediately in __slab_free. Rather than wait until
> __slab_free and potentially throw off the unlikely marking, just drop
> the lock in __slab_free. This also lets free_debug_processing take
> its own copy of the spinlock flags rather than trying to share the ones
> from __slab_free. Since there is no use for the node afterwards, change
> the return type of free_debug_processing to return an int like
> alloc_debug_processing.

Acked-by: Christoph Lameter <cl@linux.com>\

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
