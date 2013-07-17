Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 3AF366B0032
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 03:08:59 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id l18so1429142wgh.14
        for <linux-mm@kvack.org>; Wed, 17 Jul 2013 00:08:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51E34B10.5090005@asianux.com>
References: <51DF5F43.3080408@asianux.com>
	<51DF778B.8090701@asianux.com>
	<0000013fd32d0b91-4cab82b6-a24f-42e2-a1d2-ac5df2be6f4c-000000@email.amazonses.com>
	<51E34B10.5090005@asianux.com>
Date: Wed, 17 Jul 2013 10:08:57 +0300
Message-ID: <CAOJsxLFgrRgVhSAQC4HeRpWiB1xLbv3bAUhQ7pZX68xGHbEJMg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/slub.c: beautify code for removing redundancy
 'break' statement.
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Christoph Lameter <cl@linux.com>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jul 15, 2013 at 4:06 AM, Chen Gang <gang.chen@asianux.com> wrote:
> Remove redundancy 'break' statement.
>
> Signed-off-by: Chen Gang <gang.chen@asianux.com>

Christoph?

> ---
>  mm/slub.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 05ab2d5..db93fa4 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -878,7 +878,6 @@ static int on_freelist(struct kmem_cache *s, struct page *page, void *search)
>                                 object_err(s, page, object,
>                                         "Freechain corrupt");
>                                 set_freepointer(s, object, NULL);
> -                               break;
>                         } else {
>                                 slab_err(s, page, "Freepointer corrupt");
>                                 page->freelist = NULL;
> --
> 1.7.7.6
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
