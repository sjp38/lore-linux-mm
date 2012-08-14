Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 2EFAA6B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 14:43:49 -0400 (EDT)
Received: by qafk30 with SMTP id k30so4128714qaf.14
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 11:43:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120809135634.298829888@linux.com>
References: <20120809135623.574621297@linux.com>
	<20120809135634.298829888@linux.com>
Date: Wed, 15 Aug 2012 03:43:48 +0900
Message-ID: <CAAmzW4MkR8Bug8QNtPH4ghiXUYtL7UwTAt9EEYUm7_dUybF88w@mail.gmail.com>
Subject: Re: Common11r [05/20] Move list_add() to slab_common.c
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

2012/8/9 Christoph Lameter <cl@linux.com>:
> Move the code to append the new kmem_cache to the list of slab caches to
> the kmem_cache_create code in the shared code.
>
> This is possible now since the acquisition of the mutex was moved into
> kmem_cache_create().
>
> V1->V2:
>         - SLOB: Add code to remove the slab from list
>          (will be removed a couple of patches down when we also move the
>          list_del to common code).

There is no code for "SLOB: Add code to remove the slab from list"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
