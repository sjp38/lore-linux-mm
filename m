Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id C30276B0262
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 17:17:45 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id wk8so114596880pab.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 14:17:45 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id wz7si42279413pab.268.2016.09.21.14.10.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 14:10:51 -0700 (PDT)
Received: by mail-pa0-x232.google.com with SMTP id wk8so21890573pab.1
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 14:10:51 -0700 (PDT)
Date: Wed, 21 Sep 2016 14:10:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] mm/vmalloc.c: correct a few logic error for
 __insert_vmap_area()
In-Reply-To: <57E20B54.5020408@zoho.com>
Message-ID: <alpine.DEB.2.10.1609211408140.20971@chino.kir.corp.google.com>
References: <57E20B54.5020408@zoho.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, mingo@kernel.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On Wed, 21 Sep 2016, zijun_hu wrote:

> From: zijun_hu <zijun_hu@htc.com>
> 
> correct a few logic error for __insert_vmap_area() since the else
> if condition is always true and meaningless
> 
> in order to fix this issue, if vmap_area inserted is lower than one
> on rbtree then walk around left branch; if higher then right branch
> otherwise intersects with the other then BUG_ON() is triggered
> 

Under normal operation, you're right that the "else if" conditional should 
always succeed: we don't want to BUG() unless there's a bug.  The original 
code can catch instances when va->va_start == tmp_va->va_end where we 
should BUG().  Your code silently ignores it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
