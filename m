Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id BAEA66B005A
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 05:58:22 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so11827801pbb.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2012 02:58:21 -0700 (PDT)
Date: Mon, 16 Jul 2012 02:58:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
In-Reply-To: <1342407840.3190.5.camel@lorien2>
Message-ID: <alpine.DEB.2.00.1207160257420.11472@chino.kir.corp.google.com>
References: <1342221125.17464.8.camel@lorien2> <alpine.DEB.2.00.1207140216040.20297@chino.kir.corp.google.com> <CAOJsxLE3dDd01WaAp5UAHRb0AiXn_s43M=Gg4TgXzRji_HffEQ@mail.gmail.com> <1342407840.3190.5.camel@lorien2>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shuah Khan <shuah.khan@hp.com>
Cc: Pekka Enberg <penberg@kernel.org>, cl@linux.com, glommer@parallels.com, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shuahkhan@gmail.com

On Sun, 15 Jul 2012, Shuah Khan wrote:

> I can work on reshuffling the code. Do have a question though. This
> following sanity check is currently done only when CONFIG_DEBUG_VM is
> defined. However, it does appear to be something that is that should be
> checked even in regular path.
> 
> struct kmem_cache *kmem_cache_create(const char *name, size_t size,
> size_t align,
>                 unsigned long flags, void (*ctor)(void *))
> {
>         struct kmem_cache *s = NULL;
> 
> #ifdef CONFIG_DEBUG_VM
>         if (!name || in_interrupt() || size < sizeof(void *) ||
>                 size > KMALLOC_MAX_SIZE) {
>                 printk(KERN_ERR "kmem_cache_create(%s) integrity check"
>                         " failed\n", name);
>                 goto out;
>         }
> #endif
> 

Agreed, this shouldn't depend on CONFIG_DEBUG_VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
