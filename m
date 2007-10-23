Received: by rv-out-0910.google.com with SMTP id l15so1136073rvb
        for <linux-mm@kvack.org>; Tue, 23 Oct 2007 00:52:29 -0700 (PDT)
Message-ID: <84144f020710230052t3dc7e402ka2d8ede6db81618a@mail.gmail.com>
Date: Tue, 23 Oct 2007 10:52:28 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] Fix warning in mm/slub.c
In-Reply-To: <20071023143212.8D2E.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071018122345.514F.Y-GOTO@jp.fujitsu.com>
	 <20071023042153.GA20693@lixom.net>
	 <20071023143212.8D2E.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Olof Johansson <olof@lixom.net>, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On 10/23/07, Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
> > "Make kmem_cache_node for SLUB on memory online to avoid panic" introduced
> > the following:
> >
> > mm/slub.c:2737: warning: passing argument 1 of 'atomic_read' from
> > incompatible pointer type
> >
> >
> > Signed-off-by: Olof Johansson <olof@lixom.net>
> >
> >
> > diff --git a/mm/slub.c b/mm/slub.c
> > index aac1dd3..bcdb2c8 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -2734,7 +2734,7 @@ static void slab_mem_offline_callback(void *arg)
> >                        * and offline_pages() function shoudn't call this
> >                        * callback. So, we must fail.
> >                        */
> > -                     BUG_ON(atomic_read(&n->nr_slabs));
> > +                     BUG_ON(atomic_long_read(&n->nr_slabs));
> >
> >                       s->node[offline_node] = NULL;
> >                       kmem_cache_free(kmalloc_caches, n);
>
>
> Oops, yes. Thanks.
>
> Acked-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
