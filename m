Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 483B26B0089
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 04:29:32 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so20411231pac.3
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 01:29:32 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id nx16si52240005pdb.251.2014.08.25.01.29.30
        for <linux-mm@kvack.org>;
        Mon, 25 Aug 2014 01:29:31 -0700 (PDT)
Date: Mon, 25 Aug 2014 17:29:32 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/5] mm/slab_common: move kmem_cache definition to
 internal header
Message-ID: <20140825082932.GC13475@js1304-P5Q-DELUXE>
References: <1408608562-20339-1-git-send-email-iamjoonsoo.kim@lge.com>
 <53F5AD88.9050303@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53F5AD88.9050303@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 21, 2014 at 04:27:52PM +0800, Zhang Yanfei wrote:
> Hello Joonsoo,

Hello. :)

> 
> Seems like this is a cleanup patchset. I want to mention another
> tiny cleanup here.

I think these are not only cleanup but also build improvement.

> You removed the "struct slab" before but it seems there is still
> a slab_page field in page descriptor left and has no user now, right?

Yes, you are right. I will do it in next spin. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
