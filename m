Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4563C6B0264
	for <linux-mm@kvack.org>; Sat, 19 Oct 2013 18:41:17 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so6202918pab.25
        for <linux-mm@kvack.org>; Sat, 19 Oct 2013 15:41:16 -0700 (PDT)
Received: from psmtp.com ([74.125.245.202])
        by mx.google.com with SMTP id gj2si5116583pac.167.2013.10.19.15.41.15
        for <linux-mm@kvack.org>;
        Sat, 19 Oct 2013 15:41:16 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 00/15] slab: overload struct slab over struct page to reduce memory usage
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
Date: Sat, 19 Oct 2013 15:41:13 -0700
In-Reply-To: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
	(Joonsoo Kim's message of "Wed, 16 Oct 2013 17:43:57 +0900")
Message-ID: <87y55oubna.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> There is two main topics in this patchset. One is to reduce memory usage
> and the other is to change a management method of free objects of a slab.

I did a quick read over the whole patchset and it looks good to me. I
especially like how much code you remove. And of course the benchmarks
are looking good to. Thanks for cleaning up this old code.

Acked-by: Andi Kleen <ak@linux.intel.com>

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
