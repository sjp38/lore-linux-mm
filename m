Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8CE996B026A
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 19:15:48 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id wk8so120443388pab.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 16:15:48 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id s6si589867pfj.195.2016.09.21.16.15.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 16:15:47 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id z123so23791177pfz.2
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 16:15:47 -0700 (PDT)
Date: Wed, 21 Sep 2016 16:15:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] mm/vmalloc.c: correct a few logic error for
 __insert_vmap_area()
In-Reply-To: <c5435f6f-d945-fae1-c17e-04530be08421@zoho.com>
Message-ID: <alpine.DEB.2.10.1609211612280.42217@chino.kir.corp.google.com>
References: <57E20B54.5020408@zoho.com> <alpine.DEB.2.10.1609211408140.20971@chino.kir.corp.google.com> <034db3ec-e2dc-a6da-6dab-f0803900e19d@zoho.com> <alpine.DEB.2.10.1609211544510.41473@chino.kir.corp.google.com>
 <c5435f6f-d945-fae1-c17e-04530be08421@zoho.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, mingo@kernel.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On Thu, 22 Sep 2016, zijun_hu wrote:

> > We don't support inserting when va->va_start == tmp_va->va_end, plain and 
> > simple.  There's no reason to do so.  NACK to the patch.
> > 
> i am sorry i disagree with you because
> 1) in almost all context of vmalloc, original logic treat the special case as normal
>    for example, __find_vmap_area() or alloc_vmap_area()

The ranges are [start, end) like everywhere else.  __find_vmap_area() is 
implemented as such for the passed address.  The address is aligned in 
alloc_vmap_area(), there's no surprise here.  The logic is correct in 
__insert_vmap_area().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
