Received: by wr-out-0506.google.com with SMTP id i11so15402wra
        for <linux-mm@kvack.org>; Fri, 04 Aug 2006 08:56:24 -0700 (PDT)
Message-ID: <84144f020608040856u17855491k9426b064ce9feec2@mail.gmail.com>
Date: Fri, 4 Aug 2006 18:56:23 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [hch: [PATCH 1/3] slab: clean up leak tracking ifdefs a little bit]
In-Reply-To: <20060804151621.GD29422@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20060804151621.GD29422@lst.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On 8/4/06, Christoph Hellwig <hch@lst.de> wrote:
> +#ifndef CONFIG_DEBUG_SLAB
>  void *__kmalloc(size_t size, gfp_t flags)
>  {
> -#ifndef CONFIG_DEBUG_SLAB
> -       return __do_kmalloc(size, flags, NULL);
> -#else
>         return __do_kmalloc(size, flags, __builtin_return_address(0));

Other way around. You want to pass NULL when debugging is disabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
