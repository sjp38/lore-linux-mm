Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id B0FC16B0037
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 10:26:50 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id x12so749645qac.7
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 07:26:50 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id g101si2385108qge.34.2014.06.18.07.26.49
        for <linux-mm@kvack.org>;
        Wed, 18 Jun 2014 07:26:49 -0700 (PDT)
Date: Wed, 18 Jun 2014 09:26:46 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] mm: slab.h: wrap the whole file with guarding macro
In-Reply-To: <1403100695-1350-1-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.11.1406180926310.28208@gentwo.org>
References: <1403100695-1350-1-git-send-email-a.ryabinin@samsung.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 18 Jun 2014, Andrey Ryabinin wrote:

> Guarding section:
> 	#ifndef MM_SLAB_H
> 	#define MM_SLAB_H
> 	...
> 	#endif
> currently doesn't cover the whole mm/slab.h. It seems like it was
> done unintentionally.
>
> Wrap the whole file by moving closing #endif to the end of it.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
