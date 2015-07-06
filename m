Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id C75E42802C8
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 15:26:04 -0400 (EDT)
Received: by igcsj18 with SMTP id sj18so242961504igc.1
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 12:26:04 -0700 (PDT)
Received: from mail1.windriver.com (mail1.windriver.com. [147.11.146.13])
        by mx.google.com with ESMTPS id b18si14171305igr.17.2015.07.06.12.26.03
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Jul 2015 12:26:04 -0700 (PDT)
Date: Mon, 6 Jul 2015 15:25:26 -0400
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH v2] mm: nommu: fix typos in comment blocks
Message-ID: <20150706192525.GA16724@windriver.com>
References: <1436155277-21769-1-git-send-email-yamada.masahiro@socionext.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1436155277-21769-1-git-send-email-yamada.masahiro@socionext.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Christoph Hellwig <hch@lst.de>, Leon Romanovsky <leon@leon.nu>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

[[PATCH v2] mm: nommu: fix typos in comment blocks] On 06/07/2015 (Mon 13:01) Masahiro Yamada wrote:

> continguos -> contiguous
> 
> Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>

I'd suggested this go via the trivial tree, but instead I see it is in
my inbox now, and still in everyone else's inbox, and yet not Cc'd to
the trivial tree, which leaves me confused...

Paul.
--


> ---
> 
> Changes in v2:
>   -  Remove '.' from the end of the subject
> 
>  mm/nommu.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/nommu.c b/mm/nommu.c
> index 58ea364..0b34f40 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -324,12 +324,12 @@ long vwrite(char *buf, char *addr, unsigned long count)
>  }
>  
>  /*
> - *	vmalloc  -  allocate virtually continguos memory
> + *	vmalloc  -  allocate virtually contiguous memory
>   *
>   *	@size:		allocation size
>   *
>   *	Allocate enough pages to cover @size from the page level
> - *	allocator and map them into continguos kernel virtual space.
> + *	allocator and map them into contiguous kernel virtual space.
>   *
>   *	For tight control over page level allocator and protection flags
>   *	use __vmalloc() instead.
> @@ -341,12 +341,12 @@ void *vmalloc(unsigned long size)
>  EXPORT_SYMBOL(vmalloc);
>  
>  /*
> - *	vzalloc - allocate virtually continguos memory with zero fill
> + *	vzalloc - allocate virtually contiguous memory with zero fill
>   *
>   *	@size:		allocation size
>   *
>   *	Allocate enough pages to cover @size from the page level
> - *	allocator and map them into continguos kernel virtual space.
> + *	allocator and map them into contiguous kernel virtual space.
>   *	The memory allocated is set to zero.
>   *
>   *	For tight control over page level allocator and protection flags
> @@ -420,7 +420,7 @@ void *vmalloc_exec(unsigned long size)
>   *	@size:		allocation size
>   *
>   *	Allocate enough 32bit PA addressable pages to cover @size from the
> - *	page level allocator and map them into continguos kernel virtual space.
> + *	page level allocator and map them into contiguous kernel virtual space.
>   */
>  void *vmalloc_32(unsigned long size)
>  {
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
