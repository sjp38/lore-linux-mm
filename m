Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD0E6B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 11:13:48 -0500 (EST)
Received: by mail-io0-f172.google.com with SMTP id z135so127492664iof.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 08:13:48 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id b19si5281665igr.40.2016.02.26.08.13.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 26 Feb 2016 08:13:48 -0800 (PST)
Date: Fri, 26 Feb 2016 10:13:47 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 12/17] mm/slab: do not change cache size if debug
 pagealloc isn't possible
In-Reply-To: <1456466484-3442-13-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1602261013140.24939@east.gentwo.org>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com> <1456466484-3442-13-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 26 Feb 2016, js1304@gmail.com wrote:

> We can fail to setup off slab in some conditions.  Even in this case,
> debug pagealloc increases cache size to PAGE_SIZE in advance and it is
> waste because debug pagealloc cannot work for it when it isn't the off
> slab.  To improve this situation, this patch checks first that this cache
> with increased size is suitable for off slab.  It actually increases cache
> size when it is suitable for off-slab, so possible waste is removed.

Maybe add some explanations to the code? You tried to simplify it earlier
and make it understandable. This makes it difficult to understand it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
