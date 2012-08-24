Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id C4CD56B0082
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 12:15:17 -0400 (EDT)
Date: Fri, 24 Aug 2012 16:15:16 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] slub: correct the calculation of the number of cpu
 objects in get_partial_node
In-Reply-To: <1345824303-30292-2-git-send-email-js1304@gmail.com>
Message-ID: <00000139596a800b-875d7863-23ac-44a5-8710-ea357f3df8a8-000000@email.amazonses.com>
References: <Yes> <1345824303-30292-1-git-send-email-js1304@gmail.com> <1345824303-30292-2-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 25 Aug 2012, Joonsoo Kim wrote:

> index d597530..c96e0e4 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1538,6 +1538,7 @@ static void *get_partial_node(struct kmem_cache *s,
>  {
>  	struct page *page, *page2;
>  	void *object = NULL;
> +	int cpu_slab_objects = 0, pobjects = 0;

We really need be clear here.

One counter is for the numbe of objects in the per cpu slab and the other
for the objects in tbhe per cpu partial lists.

So I think the first name is ok. Second should be similar

cpu_partial_objects?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
