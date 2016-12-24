Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C7F256B0038
	for <linux-mm@kvack.org>; Sat, 24 Dec 2016 18:10:06 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id p127so295612615iop.5
        for <linux-mm@kvack.org>; Sat, 24 Dec 2016 15:10:06 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [69.252.207.34])
        by mx.google.com with ESMTPS id 81si27439385ioe.163.2016.12.24.15.10.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Dec 2016 15:10:06 -0800 (PST)
Date: Sat, 24 Dec 2016 17:09:03 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: do not merge cache if slub_debug contains a
 never-merge flag
In-Reply-To: <20161223190023.GA9644@lp-laptop-d>
Message-ID: <alpine.DEB.2.20.1612241708280.9536@east.gentwo.org>
References: <20161222235959.GC6871@lp-laptop-d> <alpine.DEB.2.20.1612231228340.21172@east.gentwo.org> <20161223190023.GA9644@lp-laptop-d>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grygorii Maistrenko <grygoriimkd@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 23 Dec 2016, Grygorii Maistrenko wrote:

> > struct kmem_cache *ind_mergeable(size_t size, size_t align,
> >                 unsigned long flags, const char *name, void (*ctor)(void *))
> > {
> >         struct kmem_cache *s;
> >
> >         if (slab_nomerge || (flags & SLAB_NEVER_MERGE))    <----- !!!!!!
> >                 return NULL;
>
> This one check is done on flags passed to kmem_cache_create().
>
> >
> >         if (ctor)
> >                 return NULL;
> >
> >         size = ALIGN(size, sizeof(void *));
> >         align = calculate_alignment(flags,
> 	flags = kmem_cache_flags(size, flags, name, NULL);
>
> I added here the missing line. This updates flags from commandline and
> after this we do not check it.

Then please move the check down below the flags update.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
