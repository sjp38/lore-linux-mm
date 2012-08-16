Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 428506B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 02:25:48 -0400 (EDT)
Received: by wibhm6 with SMTP id hm6so286352wib.8
        for <linux-mm@kvack.org>; Wed, 15 Aug 2012 23:25:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344019897-3769-1-git-send-email-glommer@parallels.com>
References: <1344019897-3769-1-git-send-email-glommer@parallels.com>
Date: Thu, 16 Aug 2012 09:25:46 +0300
Message-ID: <CAOJsxLEkJGgu7mnFXwqFewvho7AT+rC1vk0=_yMOKQTKtaTThQ@mail.gmail.com>
Subject: Re: [PATCH v2] slub: use free_page instead of put_page for freeing
 kmalloc allocation
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>

On Fri, Aug 3, 2012 at 9:51 PM, Glauber Costa <glommer@parallels.com> wrote:
> When freeing objects, the slub allocator will most of the time free
> empty pages by calling __free_pages(). But high-order kmalloc will be
> diposed by means of put_page() instead. It makes no sense to call
> put_page() in kernel pages that are provided by the object allocators,
> so we shouldn't be doing this ourselves. Aside from the consistency
> change, we don't change the flow too much. put_page()'s would call its
> dtor function, which is __free_pages. We also already do all of the
> Compound page tests ourselves, and the Mlock test we lose don't really
> matter.
>
> [v2: modified Changelog ]
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Acked-by: Christoph Lameter <cl@linux.com>
> CC: David Rientjes <rientjes@google.com>
> CC: Pekka Enberg <penberg@kernel.org>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
