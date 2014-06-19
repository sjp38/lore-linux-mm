Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id B08966B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 03:17:41 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id 10so1167977lbg.23
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 00:17:40 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id g4si4122557lbs.30.2014.06.19.00.17.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jun 2014 00:17:40 -0700 (PDT)
Date: Thu, 19 Jun 2014 11:17:29 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH] mm: slab.h: wrap the whole file with guarding macro
Message-ID: <20140619071729.GB20390@esperanza>
References: <1403100695-1350-1-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1403100695-1350-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jun 18, 2014 at 06:11:35PM +0400, Andrey Ryabinin wrote:
> Guarding section:
> 	#ifndef MM_SLAB_H
> 	#define MM_SLAB_H
> 	...
> 	#endif
> currently doesn't cover the whole mm/slab.h. It seems like it was
> done unintentionally.
> 
> Wrap the whole file by moving closing #endif to the end of it.
> 
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
