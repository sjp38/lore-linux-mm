Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 986526B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 00:48:15 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id w23so1414498plk.5
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 21:48:15 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b5-v6sor520231ple.5.2018.02.08.21.48.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Feb 2018 21:48:14 -0800 (PST)
Date: Fri, 9 Feb 2018 14:48:10 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 1/2] zsmalloc: introduce zs_huge_object() function
Message-ID: <20180209054810.GD689@jagdpanzerIV>
References: <20180207092919.19696-1-sergey.senozhatsky@gmail.com>
 <20180207092919.19696-2-sergey.senozhatsky@gmail.com>
 <20180208163006.GB17354@rapoport-lnx>
 <20180209025520.GA3423@jagdpanzerIV>
 <20180209041046.GB23828@bombadil.infradead.org>
 <20180209053630.GC689@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180209053630.GC689@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (02/09/18 14:36), Sergey Senozhatsky wrote:
> +/**
> + * zs_huge_object() - Test if a compressed object's size is too big for normal
> + *                    zspool classes and it will be stored in a huge class.
> + * @sz: Size in bytes of the compressed object.
> + *
> + * The functions checks if the object's size falls into huge_class area.
> + * We must take ZS_HANDLE_SIZE into account and test the actual size we
> + * are going to use up, because zs_malloc() unconditionally adds the
> + * handle size before it performs size_class lookup.
> + *
> + * Context: Any context.
> + *
> + * Return:
> + * * true  - The object's size is too big, it will be stored in a huge class.
> + * * false - The object will be store in normal zspool classes.
> + */
> ---
> 
> looks OK?

Modulo silly typos... and broken English.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
