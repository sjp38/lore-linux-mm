Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 906806B025A
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 12:29:33 -0400 (EDT)
Received: by qgii95 with SMTP id i95so27790415qgi.2
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 09:29:33 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id 141si1864356qhr.64.2015.07.30.09.29.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 09:29:32 -0700 (PDT)
Date: Thu, 30 Jul 2015 11:29:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slab:Fix the unexpected index mapping result of kmalloc_size(INDEX_NODE
 + 1)
In-Reply-To: <20150729152803.67f593847050419a8696fe28@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1507301128190.4907@east.gentwo.org>
References: <OF591717D2.930C6B40-ON48257E7D.0017016C-48257E7D.0020AFB4@zte.com.cn> <20150729152803.67f593847050419a8696fe28@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: liu.hailong6@zte.com.cn, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, jiang.xuexin@zte.com.cn, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>

On Wed, 29 Jul 2015, Andrew Morton wrote:

> From: Liuhailong <liu.hailong6@zte.com.cn>
> Subject: slab: fix unexpected index mapping result of kmalloc_size(INDEX_NODE + 1)

Well its a clean fix. Does the intended check in a better way.

Acked-by: Christoph Lameter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
