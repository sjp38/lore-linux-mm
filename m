Received: by wx-out-0506.google.com with SMTP id h31so669955wxd
        for <linux-mm@kvack.org>; Thu, 02 Aug 2007 05:04:07 -0700 (PDT)
Message-ID: <b6fcc0a0708020504j7588061fq7e70a50499dcbdfe@mail.gmail.com>
Date: Thu, 2 Aug 2007 16:04:06 +0400
From: "Alexey Dobriyan" <adobriyan@gmail.com>
Subject: Re: [PATCH] type safe allocator
In-Reply-To: <E1IGYuK-0001Jj-00@dorka.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
	 <E1IGYuK-0001Jj-00@dorka.pomaz.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 8/2/07, Miklos Szeredi <miklos@szeredi.hu> wrote:
> The linux kernel doesn't have a type safe object allocator a-la new()
> in C++ or g_new() in glib.
>
> Introduce two helpers for this purpose:
>
>    alloc_struct(type, gfp_flags);
>
>    zalloc_struct(type, gfp_flags);

ick.

> These macros take a type name (usually a 'struct foo') as first
> argument

So one has to type struct twice.

> and the usual gfp-flags as second argument.  They return a
> pointer cast to 'type *'.
>
> The traditional forms of allocating a structure are:
>
>   fooptr = kmalloc(sizeof(*fooptr), ...);
>
>   fooptr = kmalloc(sizeof(struct foo), ...);

Key word is "traditional". Good traditional form which even half-competent
C programmers immediately parse in retina.

> The new form is preferred over these, because of it's type safety and
> more descriptive nature.

> +/**
> + * alloc_struct - allocate given type object
> + * @type: the type of the object to allocate
> + * @flags: the type of memory to allocate.
> + */
> +#define alloc_struct(type, flags) ((type *) kmalloc(sizeof(type), flags))

someone will write alloc_struct(int, GFP_KERNEL), I promise.

Can you play instead with something Lisp based which has infinetely more
potential for idioms.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
