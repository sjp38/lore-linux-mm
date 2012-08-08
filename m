Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id ADAC46B004D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 10:48:44 -0400 (EDT)
Date: Wed, 8 Aug 2012 09:47:32 -0500 (CDT)
From: "Christoph Lameter (Open Source)" <cl@linux.com>
Subject: Re: Common10 [05/20] Move list_add() to slab_common.c
In-Reply-To: <CAAmzW4NSf0+eGmuprSZtPGp2u-PXzS_YKD3WdE0-zs41kscbKQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1208080945420.7756@greybox.home>
References: <20120803192052.448575403@linux.com> <20120803192150.539500555@linux.com> <CAAmzW4NSf0+eGmuprSZtPGp2u-PXzS_YKD3WdE0-zs41kscbKQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Sun, 5 Aug 2012, JoonSoo Kim wrote:

> 2012/8/4 Christoph Lameter <cl@linux.com>:
> > Move the code to append the new kmem_cache to the list of slab caches to
> > the kmem_cache_create code in the shared code.
> >
>
> Now, we need to list_del() in kmem_cache_destroy() for SLOB,
> although later patch will remove it again.

Hmmm... Ok. Guess we have to add it and remove it.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
