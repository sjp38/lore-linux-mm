Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 537436B00B0
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 15:03:34 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so3245565pab.41
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 12:03:33 -0700 (PDT)
Date: Thu, 17 Oct 2013 19:03:29 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 1/5] slab: factor out calculate nr objects in
 cache_estimate
In-Reply-To: <1381989797-29269-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000141c7cd1ab4-314fa179-ada6-4682-95a3-09228d38adf7-000000@email.amazonses.com>
References: <1381989797-29269-1-git-send-email-iamjoonsoo.kim@lge.com> <1381989797-29269-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Thu, 17 Oct 2013, Joonsoo Kim wrote:

> This logic is not simple to understand so that making separate function
> helping readability. Additionally, we can use this change in the
> following patch which implement for freelist to have another sized index
> in according to nr objects.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
