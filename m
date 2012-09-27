Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id B8F286B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 21:36:00 -0400 (EDT)
Date: Thu, 27 Sep 2012 10:39:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/3] zsmalloc: promote to lib/
Message-ID: <20120927013912.GB10229@bbox>
References: <1348649419-16494-1-git-send-email-minchan@kernel.org>
 <1348649419-16494-2-git-send-email-minchan@kernel.org>
 <CAOJsxLGjp5PAgPe3KSvMfqJEyVC4YHeP+FW3AmnCorpHqnfang@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOJsxLGjp5PAgPe3KSvMfqJEyVC4YHeP+FW3AmnCorpHqnfang@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

Hi Pekka,

On Wed, Sep 26, 2012 at 12:51:49PM +0300, Pekka Enberg wrote:
> On Wed, Sep 26, 2012 at 11:50 AM, Minchan Kim <minchan@kernel.org> wrote:
> >  lib/Kconfig                              |    2 +
> >  lib/Makefile                             |    1 +
> >  lib/zsmalloc/Kconfig                     |   18 +
> >  lib/zsmalloc/Makefile                    |    1 +
> >  lib/zsmalloc/zsmalloc.c                  | 1064 ++++++++++++++++++++++++++++++
> 
> What's wrong with mm/zsmalloc.c?

Why I put zsmalloc into under mm firstly is that Andrew had a concern
about using strut page's some fields freely in zsmalloc so he wanted
to maintain it in mm/ if I remember correctly.

So I and Nitin tried to ask the opinion to akpm several times
(at least 5 and even I sent such patch a few month ago) but didn't get
any reply from him so I guess he doesn't have any concern about that
any more.

In point of view that it's an another slab-like allocator,
it might be proper under mm but it's not popular as current mm's 
allocators(/SLUB/SLOB and page allocator).

Frankly speaking, I'm okay whether we put it to mm/ or lib/.
But it seems Nitin and Konrad like lib/ and Andrew is silent.
That's why I am biased into lib/ now.

If someone yell we should keep it to mm/ by logical claim,
I can change my mind easily.
But I've never heard abut that until now.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
