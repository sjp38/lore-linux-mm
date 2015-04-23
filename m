Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id C2A7D6B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 09:56:09 -0400 (EDT)
Received: by igbpi8 with SMTP id pi8so10603242igb.0
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 06:56:09 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id ci10si7083754igb.28.2015.04.23.06.56.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 06:56:09 -0700 (PDT)
Date: Thu, 23 Apr 2015 08:56:06 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] mm/slab_common: Support the slub_debug boot option
 on specific object size
In-Reply-To: <1429795560-29131-1-git-send-email-gavin.guo@canonical.com>
Message-ID: <alpine.DEB.2.11.1504230854430.32095@gentwo.org>
References: <1429795560-29131-1-git-send-email-gavin.guo@canonical.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Guo <gavin.guo@canonical.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@rasmusvillemoes.dk

On Thu, 23 Apr 2015, Gavin Guo wrote:

> -		if (KMALLOC_MIN_SIZE <= 64 && !kmalloc_caches[2] && i == 7)
> -			kmalloc_caches[2] = create_kmalloc_cache(NULL, 192, flags);
> +		if (i == 2)
> +			i = (KMALLOC_SHIFT_LOW - 1);
>  	}

Ok this is weird but there is a comment.

Acked-by: Christoph Lameter <cl@linux.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
