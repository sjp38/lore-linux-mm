Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9DA3E6B0005
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 05:46:02 -0500 (EST)
Received: by mail-yk0-f178.google.com with SMTP id v14so43380285ykd.3
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 02:46:02 -0800 (PST)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id n83si229824ybn.107.2016.01.21.02.46.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 21 Jan 2016 02:46:01 -0800 (PST)
Subject: Re: [Xen-devel] [PATCH] cleancache: constify cleancache_ops structure
References: <1450904784-17139-1-git-send-email-Julia.Lawall@lip6.fr>
From: David Vrabel <david.vrabel@citrix.com>
Message-ID: <56A0B6E7.9040201@citrix.com>
Date: Thu, 21 Jan 2016 10:45:59 +0000
MIME-Version: 1.0
In-Reply-To: <1450904784-17139-1-git-send-email-Julia.Lawall@lip6.fr>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>, linux-mm@kvack.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, David
 Vrabel <david.vrabel@citrix.com>, xen-devel@lists.xenproject.org, Boris
 Ostrovsky <boris.ostrovsky@oracle.com>

On 23/12/15 21:06, Julia Lawall wrote:
> The cleancache_ops structure is never modified, so declare it as const.
> 
> This also removes the __read_mostly declaration on the cleancache_ops
> variable declaration, since it seems redundant with const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
> 
> Not sure that the __read_mostly change is correct.  Does it apply to the
> variable, or to what the variable points to?

The variable, so...

> --- a/mm/cleancache.c
> +++ b/mm/cleancache.c
> @@ -22,7 +22,7 @@
>   * cleancache_ops is set by cleancache_register_ops to contain the pointers
>   * to the cleancache "backend" implementation functions.
>   */
> -static struct cleancache_ops *cleancache_ops __read_mostly;
> +static const struct cleancache_ops *cleancache_ops;

...you want to retain the __read_mostly here.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
