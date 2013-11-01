Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 32A556B0035
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 15:09:51 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id kp14so4438604pab.4
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 12:09:50 -0700 (PDT)
Received: from psmtp.com ([74.125.245.151])
        by mx.google.com with SMTP id sg3si5202771pbb.313.2013.11.01.12.09.49
        for <linux-mm@kvack.org>;
        Fri, 01 Nov 2013 12:09:50 -0700 (PDT)
Date: Fri, 1 Nov 2013 19:09:47 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 17/15] slab: replace non-existing 'struct freelist *'
 with 'void *'
In-Reply-To: <1383127441-30563-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <0000014215124298-73ed0d4f-b9ff-4645-87de-87a60abe4dc2-000000@email.amazonses.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com> <1383127441-30563-1-git-send-email-iamjoonsoo.kim@lge.com> <1383127441-30563-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Wed, 30 Oct 2013, Joonsoo Kim wrote:

> There is no 'strcut freelist', but codes use pointer to 'struct freelist'.
> Although compiler doesn't complain anything about this wrong usage and
> codes work fine, but fixing it is better.

I think its better to avoid "void" when possible. struct freelist is good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
