Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0F57D900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 23:50:33 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so21385768pdj.3
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 20:50:32 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id s8si3786128pdp.253.2015.06.03.20.50.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 20:50:32 -0700 (PDT)
Received: by pabqy3 with SMTP id qy3so20393033pab.3
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 20:50:31 -0700 (PDT)
Date: Thu, 4 Jun 2015 12:50:25 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH 03/10] zsmalloc: introduce zs_can_compact() function
Message-ID: <20150604035025.GH2241@blaptop>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1432911928-14654-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20150604025533.GE2241@blaptop>
 <20150604031514.GE1951@swordfish>
 <20150604033014.GG2241@blaptop>
 <20150604034230.GH1951@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150604034230.GH1951@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 04, 2015 at 12:42:30PM +0900, Sergey Senozhatsky wrote:
> On (06/04/15 12:30), Minchan Kim wrote:
> > > -- free objects in class: 5 (free-objs class capacity)
> > > -- page1: inuse 2
> > > -- page2: inuse 2
> > > -- page3: inuse 3
> > > -- page4: inuse 2
> > 
> > What scenario do you have a cocern?
> > Could you describe this example more clear?
> 
> you mean "how is this even possible"?

No I meant. I couldn't understand your terms. Sorry.

What free-objs class capacity is?
page1 is zspage?

Let's use consistent terms between us.

For example, maxobj-per-zspage is 4.
A is allocated and used. X is allocated but not used.
so we can draw a zspage below.

        AAXX

So we can draw several zspages linked list as below

AAXX - AXXX - AAAX

Could you describe your problem again?

Sorry.


> 
> well, for example,
> 
> make -jX
> make clean
> 
> can introduce a significant fragmentation. no new objects, just random
> objs removal. assuming that we keep some of the objects, allocated during
> compilation.
> 
> e.g.
> 
> ...
> 
> page1
>   allocate baz.so
>   allocate foo.o
> page2
>   allocate bar.o
>   allocate foo.so
> ...
> pageN
> 
> 
> 
> now `make clean`
> 
> page1:
>   allocated baz.so
>   empty
> 
> page2
>   empty
>   allocated foo.so
> 
> ...
> 
> pageN
> 
> in the worst case, every page can turn out to be ALMOST_EMPTY.
> 
> 	-ss

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
