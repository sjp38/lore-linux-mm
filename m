Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 81B8B6B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 07:34:51 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id d21so2117463pll.12
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 04:34:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p89sor656371pfk.85.2018.02.09.04.34.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Feb 2018 04:34:50 -0800 (PST)
Date: Fri, 9 Feb 2018 21:34:46 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH 1/2] zsmalloc: introduce zs_huge_object() function
Message-ID: <20180209123446.GB485@tigerII.localdomain>
References: <20180207092919.19696-1-sergey.senozhatsky@gmail.com>
 <20180207092919.19696-2-sergey.senozhatsky@gmail.com>
 <20180208163006.GB17354@rapoport-lnx>
 <20180209025520.GA3423@jagdpanzerIV>
 <20180209041046.GB23828@bombadil.infradead.org>
 <20180209053630.GC689@jagdpanzerIV>
 <20180209111102.GB2044@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180209111102.GB2044@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Matthew Wilcox <willy@infradead.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (02/09/18 13:11), Mike Rapoport wrote:
[..]
> > +/**
> > + * zs_huge_object() - Test if a compressed object's size is too big for normal
> > + *                    zspool classes and it will be stored in a huge class.
> 
> Maybe "it should be stored ..."?

Agreed.

> > + * @sz: Size in bytes of the compressed object.
> > + *
> > + * The functions checks if the object's size falls into huge_class area.
> > + * We must take ZS_HANDLE_SIZE into account and test the actual size we
> 
>                 ^ %ZS_HANDLE_SIZE

Indeed. ``%CONST``

> > + * are going to use up, because zs_malloc() unconditionally adds the
> 
> I think 's/use up/use/' here

Agreed.

> > + * handle size before it performs size_class lookup.
> 
>                                    ^ &size_class

OK. ``&struct name``

Thanks for reviewing it!

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
