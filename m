Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 669686B0253
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 10:29:11 -0400 (EDT)
Received: by igxx6 with SMTP id x6so18500119igx.1
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 07:29:11 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id j7si6993760igh.44.2015.09.18.07.29.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 18 Sep 2015 07:29:09 -0700 (PDT)
Date: Fri, 18 Sep 2015 09:29:07 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slab: fix unexpected index mapping result of
 kmalloc_size(INDEX_NODE+1)
In-Reply-To: <1442552475-21015-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.11.1509180928370.10168@east.gentwo.org>
References: <1442552475-21015-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 18 Sep 2015, Joonsoo Kim wrote:

> This patch fixes the problem of kmalloc_size(INDEX_NODE + 1) and removes
> the BUG by adding 'size >= 256' check to guarantee that all necessary
> small sized slabs are initialized regardless sequence of slab size in
> mapping table.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
