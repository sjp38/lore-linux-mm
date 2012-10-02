Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 9163E6B006E
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 10:47:37 -0400 (EDT)
Received: by obcva7 with SMTP id va7so7767044obc.14
        for <linux-mm@kvack.org>; Tue, 02 Oct 2012 07:47:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013a0e5f601a-e8401015-afdb-4958-b562-0d1d5d2d6f15-000000@email.amazonses.com>
References: <20120928191715.368450474@linux.com>
	<0000013a0e5f601a-e8401015-afdb-4958-b562-0d1d5d2d6f15-000000@email.amazonses.com>
Date: Tue, 2 Oct 2012 23:47:36 +0900
Message-ID: <CAAmzW4NW4LgXOxXQvRVgBhJ2Vxyijx0bugGDPgBjz2kUY=DAuA@mail.gmail.com>
Subject: Re: CK2 [03/15] slub: Use a statically allocated kmem_cache boot
 structure for bootstrap
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Hi, Christoph.

2012/9/29 Christoph Lameter <cl@linux.com>:
> @@ -3930,6 +3905,10 @@ int __kmem_cache_create(struct kmem_cach
>         if (err)
>                 return err;
>
> +       /* Mutex is not taken during early boot */
> +       if (slab_state <= UP)
> +               return 0;
> +
>         mutex_unlock(&slab_mutex);
>         err = sysfs_slab_add(s);
>         mutex_lock(&slab_mutex);

This addition should go to previous patch "create common functions for
boot slab creation".
In there, create_boot_cache() call __kmem_cache_create(), and then
mutex_unlock() is called without taking mutext.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
