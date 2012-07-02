Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id B12466B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 06:52:43 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so9547302lbj.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2012 03:52:41 -0700 (PDT)
Date: Mon, 2 Jul 2012 13:52:38 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 0/4] Proposed slab patches as basis for memcg
In-Reply-To: <1339676244-27967-1-git-send-email-glommer@parallels.com>
Message-ID: <alpine.LFD.2.02.1207021351210.1916@tux.localdomain>
References: <1339676244-27967-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org

On Thu, 14 Jun 2012, Glauber Costa wrote:
> These four patches are sat in my tree for kmem memcg work.
> All of them are preparation patches that touch the allocators
> to make them more consistent, allowing me to later use them
> from common code.
> 
> In this current form, they are supposed to be applied after
> Cristoph's series. They are not, however, dependent on it.
> 
> Glauber Costa (4):
>   slab: rename gfpflags to allocflags
>   provide a common place for initcall processing in kmem_cache
>   slab: move FULL state transition to an initcall
>   make CFLGS_OFF_SLAB visible for all slabs
> 
>  include/linux/slab.h     |    2 ++
>  include/linux/slab_def.h |    2 +-
>  mm/slab.c                |   40 +++++++++++++++++++---------------------
>  mm/slab.h                |    1 +
>  mm/slab_common.c         |    5 +++++
>  mm/slob.c                |    5 +++++
>  mm/slub.c                |    4 +---
>  7 files changed, 34 insertions(+), 25 deletions(-)

I applied the first patch. Rest of them don't apply on top of slab/next 
branch because it's missing some of the key patches from Christoph's 
series. Did anyone fix them up while I was offline?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
