Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id ECC396B0070
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 11:42:56 -0400 (EDT)
Received: by iecrt8 with SMTP id rt8so106682861iec.0
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 08:42:56 -0700 (PDT)
Received: from resqmta-po-06v.sys.comcast.net (resqmta-po-06v.sys.comcast.net. [2001:558:fe16:19:96:114:154:165])
        by mx.google.com with ESMTPS id i80si4163154ioi.31.2015.04.20.08.42.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 20 Apr 2015 08:42:56 -0700 (PDT)
Date: Mon, 20 Apr 2015 10:42:55 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v5] slab: Correct size_index table before replacing the
 bootstrap kmem_cache_node.
In-Reply-To: <1429542335-8379-1-git-send-email-daniel.sanders@imgtec.com>
Message-ID: <alpine.DEB.2.11.1504201041530.2264@gentwo.org>
References: <1424791511-11407-2-git-send-email-daniel.sanders@imgtec.com> <1429542335-8379-1-git-send-email-daniel.sanders@imgtec.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Sanders <daniel.sanders@imgtec.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 20 Apr 2015, Daniel Sanders wrote:

> This patch moves the initialization of the size_index table slightly
> earlier so that the first few kmem_cache_node's can be safely allocated
> when KMALLOC_MIN_SIZE is large.

I have seen this patch and acked it before.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
