Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id E73406B0036
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 05:13:29 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id y20so1747885ier.12
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 02:13:29 -0700 (PDT)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id i8si3014949igt.5.2014.06.19.02.13.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 02:13:29 -0700 (PDT)
Received: by mail-ie0-f169.google.com with SMTP id at1so1794463iec.28
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 02:13:29 -0700 (PDT)
Date: Thu, 19 Jun 2014 02:13:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: slab.h: wrap the whole file with guarding macro
In-Reply-To: <53A29158.2050809@samsung.com>
Message-ID: <alpine.DEB.2.02.1406190213070.13670@chino.kir.corp.google.com>
References: <1403100695-1350-1-git-send-email-a.ryabinin@samsung.com> <alpine.DEB.2.02.1406181321010.10339@chino.kir.corp.google.com> <53A29158.2050809@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 19 Jun 2014, Andrey Ryabinin wrote:

> I had to do some modifications in this file for some reasons, and for me it was hard to not
> notice lack of endif in the end.
> 

Ok, cool, I don't think there's any need for a stable backport in that 
case.  Thanks for fixing it!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
