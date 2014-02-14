Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id E3C3C6B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 13:50:00 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id n7so21045664qcx.30
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 10:50:00 -0800 (PST)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id i33si4486848qgf.80.2014.02.14.10.50.00
        for <linux-mm@kvack.org>;
        Fri, 14 Feb 2014 10:50:00 -0800 (PST)
Date: Fri, 14 Feb 2014 12:49:57 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 9/9] slab: remove a useless lockdep annotation
In-Reply-To: <1392361043-22420-10-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1402141248560.12887@nuc>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com> <1392361043-22420-10-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Fri, 14 Feb 2014, Joonsoo Kim wrote:

> @@ -921,7 +784,7 @@ static int transfer_objects(struct array_cache *to,
>  static inline struct alien_cache **alloc_alien_cache(int node,
>  						int limit, gfp_t gfp)
>  {
> -	return (struct alien_cache **)BAD_ALIEN_MAGIC;
> +	return NULL;
>  }
>

Why change the BAD_ALIEN_MAGIC?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
