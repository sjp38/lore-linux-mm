Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 94A516B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 04:22:34 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id fp1so10394966pdb.14
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 01:22:34 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id y7si27909119pdj.154.2014.12.01.01.22.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Dec 2014 01:22:33 -0800 (PST)
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 8A85C20B39
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 04:22:29 -0500 (EST)
Message-ID: <547C3353.9030502@iki.fi>
Date: Mon, 01 Dec 2014 11:22:27 +0200
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH v2] slab: Fix nodeid bounds check for non-contiguous node
 IDs
References: <20141201042844.GB11234@drongo>
In-Reply-To: <20141201042844.GB11234@drongo>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On 12/1/14 6:28 AM, Paul Mackerras wrote:
> ---
> v2: include the oops message in the patch description
>
>   mm/slab.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index eb2b2ea..f34e053 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3076,7 +3076,7 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
>   	void *obj;
>   	int x;
>   
> -	VM_BUG_ON(nodeid > num_online_nodes());
> +	VM_BUG_ON(nodeid < 0 || nodeid >= MAX_NUMNODES);
>   	n = get_node(cachep, nodeid);
>   	BUG_ON(!n);

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
