Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 04C7A6B006E
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 11:30:53 -0500 (EST)
Date: Tue, 15 Jan 2013 16:30:52 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slab: add a leak decoder callback
In-Reply-To: <1358143419-13074-1-git-send-email-bo.li.liu@oracle.com>
Message-ID: <0000013c3f0c8af2-361e64b5-f822-4a93-a67e-b2902bb336fc-000000@email.amazonses.com>
References: <1358143419-13074-1-git-send-email-bo.li.liu@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liu Bo <bo.li.liu@oracle.com>
Cc: linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, Zach Brown <zab@zabbo.net>, Pekka Enberg <penberg@kernel.org>

On Mon, 14 Jan 2013, Liu Bo wrote:

> This adds a leak decoder callback so that kmem_cache_destroy()
> can use to generate debugging output for the allocated objects.

Interesting idea.

> @@ -3787,6 +3789,9 @@ static int slab_unmergeable(struct kmem_cache *s)
>  	if (s->ctor)
>  		return 1;
>
> +	if (s->decoder)
> +		return 1;
> +
>  	/*
>  	 * We may have set a slab to be unmergeable during bootstrap.
>  	 */

The merge processing occurs during kmem_cache_create and you are setting
up the decoder field afterwards! Wont work.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
