Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6BB9A6B0005
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:56:02 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id p189so12803715iod.2
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 11:56:02 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id g143si404559ioe.289.2018.02.14.11.56.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 11:56:01 -0800 (PST)
Date: Wed, 14 Feb 2018 13:55:59 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
In-Reply-To: <20180214182618.14627-3-willy@infradead.org>
Message-ID: <alpine.DEB.2.20.1802141354530.28235@nuc-kabylake>
References: <20180214182618.14627-1-willy@infradead.org> <20180214182618.14627-3-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, 14 Feb 2018, Matthew Wilcox wrote:

> +#define kvzalloc_struct(p, member, n, gfp)				\
> +	(typeof(p))kvzalloc_ab_c(n,					\
> +		sizeof(*(p)->member) + __must_be_array((p)->member),	\
> +		offsetof(typeof(*(p)), member), gfp)
> +

Uppercase like the similar KMEM_CACHE related macros in
include/linux/slab.h?>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
