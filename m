Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 25B5E6B0007
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 00:52:30 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id 4so2964247plb.1
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 21:52:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i70sor454220pfi.79.2018.02.13.21.52.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Feb 2018 21:52:28 -0800 (PST)
Date: Wed, 14 Feb 2018 14:52:23 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCHv2 1/2] zsmalloc: introduce zs_huge_object() function
Message-ID: <20180214055223.GA508@jagdpanzerIV>
References: <20180207092919.19696-2-sergey.senozhatsky@gmail.com>
 <20180210082321.17798-1-sergey.senozhatsky@gmail.com>
 <20180211070539.GA13931@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180211070539.GA13931@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (02/11/18 09:05), Mike Rapoport wrote:
[..]
> > +/**
> > + * zs_huge_object() - Test if a compressed object's size is too big for normal
> > + *                    zspool classes and it shall be stored in a huge class.
> 
> I think "is should be stored" is more appropriate
> 
> > + * @sz: Size of the compressed object (in bytes).
> > + *
> > + * The function checks if the object's size falls into huge_class
> > + * area. We must take handle size into account and test the actual
> > + * size we are going to use, because zs_malloc() unconditionally
> > + * adds %ZS_HANDLE_SIZE before it performs %size_class lookup.
> 
>                                             ^ &size_class ;-)

I'm sorry, Mike. Lost in branches/versions and sent out a half baked
version.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
