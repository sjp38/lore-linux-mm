Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id E57566B0035
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 11:28:02 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so21229377pab.28
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 08:28:02 -0700 (PDT)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id zj4si208436pbb.49.2014.08.25.08.28.01
        for <linux-mm@kvack.org>;
        Mon, 25 Aug 2014 08:28:01 -0700 (PDT)
Date: Mon, 25 Aug 2014 10:27:58 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm/slab_common: commonize slab merge logic
In-Reply-To: <1408608675-20420-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.11.1408251026110.27302@gentwo.org>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com> <1408608675-20420-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 21 Aug 2014, Joonsoo Kim wrote:

> +static int __init setup_slab_nomerge(char *str)
> +{
> +	slab_nomerge = 1;
> +	return 1;
> +}
> +__setup("slub_nomerge", setup_slab_nomerge);

Uhh.. You would have to specify "slub_nomerge" to get slab to not merge
slab caches?

Otherwise this is a straightforward move into the common area.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
