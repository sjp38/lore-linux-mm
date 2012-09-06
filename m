Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 940AF6B0068
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 10:18:28 -0400 (EDT)
Date: Thu, 6 Sep 2012 14:18:24 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 4/5] mm, slob: Use only 'ret' variable for both slob
 object and returned pointer
In-Reply-To: <1346885323-15689-4-git-send-email-elezegarcia@gmail.com>
Message-ID: <000001399bf23209-1d91226b-87ea-43cf-b482-100ee4d032b1-000000@email.amazonses.com>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com> <1346885323-15689-4-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>

On Wed, 5 Sep 2012, Ezequiel Garcia wrote:

> There's no need to use two variables, 'ret' and 'm'.
> This is a minor cleanup patch, but it will allow next patch to clean
> the way tracing is done.

The compiler will fold those variables into one if possible. No need to
worry about having multiple declarations.

>  		if (!size)
>  			return ZERO_SIZE_PTR;
>
> -		m = slob_alloc(size + align, gfp, align, node);
> +		ret = slob_alloc(size + align, gfp, align, node);
>
> -		if (!m)
> +		if (!ret)
>  			return NULL;
> -		*m = size;
> -		ret = (void *)m + align;
> +		*(unsigned int *)ret = size;

An ugly cast...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
