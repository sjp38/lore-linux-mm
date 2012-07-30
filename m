Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 869316B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 06:18:38 -0400 (EDT)
Received: by weys10 with SMTP id s10so4386130wey.14
        for <linux-mm@kvack.org>; Mon, 30 Jul 2012 03:18:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1342221125.17464.8.camel@lorien2>
References: <1342221125.17464.8.camel@lorien2>
Date: Mon, 30 Jul 2012 13:18:36 +0300
Message-ID: <CAOJsxLGjnMxs9qERG5nCfGfcS3jy6Rr54Ac36WgVnOtP_pDYgQ@mail.gmail.com>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuah.khan@hp.com
Cc: cl@linux.com, glommer@parallels.com, js1304@gmail.com, shuahkhan@gmail.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>

On Sat, Jul 14, 2012 at 2:12 AM, Shuah Khan <shuah.khan@hp.com> wrote:
> The label oops is used in CONFIG_DEBUG_VM ifdef block and is defined
> outside ifdef CONFIG_DEBUG_VM block. This results in the following
> build warning when built with CONFIG_DEBUG_VM disabled. Fix to move
> label oops definition to inside a CONFIG_DEBUG_VM block.
>
> mm/slab_common.c: In function =91kmem_cache_create=92:
> mm/slab_common.c:101:1: warning: label =91oops=92 defined but not used
> [-Wunused-label]
>
> Signed-off-by: Shuah Khan <shuah.khan@hp.com>

I merged this as an obvious and safe fix for current merge window. We
need to clean this up properly for v3.7.

> ---
>  mm/slab_common.c |    2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 12637ce..aa3ca5b 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -98,7 +98,9 @@ struct kmem_cache *kmem_cache_create(const char *name, =
size_t size, size_t align
>
>         s =3D __kmem_cache_create(name, size, align, flags, ctor);
>
> +#ifdef CONFIG_DEBUG_VM
>  oops:
> +#endif
>         mutex_unlock(&slab_mutex);
>         put_online_cpus();
>
> --
> 1.7.9.5
>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
