Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id EC1DC6B00B4
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 15:05:57 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp16so2730228pbb.28
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 12:05:57 -0700 (PDT)
Date: Thu, 17 Oct 2013 19:05:54 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 04/15] slab: remove nodeid in struct slab
In-Reply-To: <1381913052-23875-5-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000141c7cf516e-9c81134b-35e0-4e75-90f2-e7706c28a9d4-000000@email.amazonses.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com> <1381913052-23875-5-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Wed, 16 Oct 2013, Joonsoo Kim wrote:

> We can get nodeid using address translation, so this field is not useful.
> Therefore, remove it.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
