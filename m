Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id C58C66B0035
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 11:58:00 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so5515181pbb.26
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 08:57:59 -0700 (PDT)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id ic8si4469276pad.95.2014.04.11.08.57.58
        for <linux-mm@kvack.org>;
        Fri, 11 Apr 2014 08:57:58 -0700 (PDT)
Date: Fri, 11 Apr 2014 10:57:54 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] slab: document kmalloc_order
In-Reply-To: <1397220736-13840-1-git-send-email-vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.10.1404111057390.13278@nuc>
References: <20140410163831.c76596b0f8d0bef39a42c63f@linux-foundation.org> <1397220736-13840-1-git-send-email-vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, penberg@kernel.org, gthelen@google.com, hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On Fri, 11 Apr 2014, Vladimir Davydov wrote:

> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index cab4c49b3e8c..3ffd2e76b5d2 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -573,6 +573,11 @@ void __init create_kmalloc_caches(unsigned long flags)
>  }
>  #endif /* !CONFIG_SLOB */
>
> +/*
> + * To avoid unnecessary overhead, we pass through large allocation requests
> + * directly to the page allocator. We use __GFP_COMP, because we will need to
> + * know the allocation order to free the pages properly in kfree.
> + */
>  void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
>  {
>  	void *ret;
>

??? kmalloc_order is defined in include/linux/slab.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
