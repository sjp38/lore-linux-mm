Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 616376B0032
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 09:53:29 -0500 (EST)
Received: by mail-qg0-f50.google.com with SMTP id e89so7694421qgf.9
        for <linux-mm@kvack.org>; Mon, 09 Feb 2015 06:53:29 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id n6si14407185qag.104.2015.02.09.06.53.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 09 Feb 2015 06:53:28 -0800 (PST)
Date: Mon, 9 Feb 2015 08:53:26 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slab_common: Use kmem_cache_free
In-Reply-To: <20150209052835.GA3559@vaishali-Ideapad-Z570>
Message-ID: <alpine.DEB.2.11.1502090853120.9956@gentwo.org>
References: <20150209052835.GA3559@vaishali-Ideapad-Z570>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaishali Thakkar <vthakkar1994@gmail.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 9 Feb 2015, Vaishali Thakkar wrote:

> Here, free memory is allocated using kmem_cache_zalloc.
> So, use kmem_cache_free instead of kfree.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
