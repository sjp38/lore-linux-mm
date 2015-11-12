Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 796866B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 00:46:26 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so54034552pac.3
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 21:46:26 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id ps2si17632227pbb.23.2015.11.11.21.46.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 21:46:25 -0800 (PST)
Received: by pasz6 with SMTP id z6so55975366pas.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 21:46:25 -0800 (PST)
Date: Wed, 11 Nov 2015 21:46:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] tools/vm/page-types: suppress gcc warnings
In-Reply-To: <20151112005455.GA1651@swordfish>
Message-ID: <alpine.DEB.2.10.1511112120020.9296@chino.kir.corp.google.com>
References: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com> <1447162326-30626-3-git-send-email-sergey.senozhatsky@gmail.com> <alpine.DEB.2.10.1511111242060.3565@chino.kir.corp.google.com> <20151112005455.GA1651@swordfish>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.10.1511112121022.9296@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 12 Nov 2015, Sergey Senozhatsky wrote:

> > This can't possibly be correct, the warnings are legitimate and the result
> > of the sigsetjmp() in the function.  You may be interested in
> > returns_twice rather than marking random automatic variables as volatile.
> 
> Hm, ok. I saw no probs with `int first' and `end' being volatile
> 

This will only happen with the undocumented change in your first patch 
which adds -O2.

I don't know what version of gcc you're using, but only "first" and "end" 
being marked volatile isn't sufficient since mere code inspection would 
show that "off" will also be clobbered -- it's part of the loop.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
