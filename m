Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3504E828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 10:22:18 -0500 (EST)
Received: by mail-io0-f181.google.com with SMTP id 77so424718345ioc.2
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 07:22:18 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id ft1si13319707igb.81.2016.01.14.07.22.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jan 2016 07:22:17 -0800 (PST)
Date: Thu, 14 Jan 2016 09:22:15 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 01/16] mm/slab: fix stale code comment
In-Reply-To: <1452749069-15334-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1601140921500.2145@east.gentwo.org>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com> <1452749069-15334-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 14 Jan 2016, Joonsoo Kim wrote:

> We use freelist_idx_t type for free object management whose size
> would be smaller than size of unsigned int. Fix it.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
