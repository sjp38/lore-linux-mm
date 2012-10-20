Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 80F736B0062
	for <linux-mm@kvack.org>; Sat, 20 Oct 2012 12:01:54 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so1606129oag.14
        for <linux-mm@kvack.org>; Sat, 20 Oct 2012 09:01:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013a7979e9c4-0f9a8d4b-34b4-45dd-baff-a4ccac7a51a6-000000@email.amazonses.com>
References: <20121019142254.724806786@linux.com>
	<0000013a7979e9c4-0f9a8d4b-34b4-45dd-baff-a4ccac7a51a6-000000@email.amazonses.com>
Date: Sun, 21 Oct 2012 01:01:53 +0900
Message-ID: <CAAmzW4M8eJYk3zvM7iEhCXJP2OU8POE80T0KDyHXWuz2WU4ByA@mail.gmail.com>
Subject: Re: CK2 [04/15] slab: Use the new create_boot_cache function to
 simplify bootstrap
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

2012/10/19 Christoph Lameter <cl@linux.com>:


> @@ -2270,7 +2245,16 @@ static int __init_refok setup_cpu_cache(
>
>         if (slab_state == DOWN) {
>                 /*
> -                * Note: the first kmem_cache_create must create the cache
> +                * Note: Creation of first cache (kmem_cache).
> +                * The setup_list3s is taken care
> +                * of by the caller of __kmem_cache_create
> +                */
> +               cachep->array[smp_processor_id()] = &initarray_generic.cache;
> +               slab_state = PARTIAL;
> +       } else
> +       if (slab_state == PARTIAL) {
> +               /*
> +                * Note: the second kmem_cache_create must create the cache
>                  * that's used by kmalloc(24), otherwise the creation of
>                  * further caches will BUG().
>                  */

Minor nitpick is here

} else
if (slab_state = PARTIAL) {
==>
else if (slab_state == PARTIAL)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
