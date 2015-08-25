Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 74A406B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:59:42 -0400 (EDT)
Received: by iodb91 with SMTP id b91so188843683iod.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:59:42 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id u34si9882026ioi.166.2015.08.25.07.59.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 25 Aug 2015 07:59:41 -0700 (PDT)
Date: Tue, 25 Aug 2015 09:59:40 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 02/10] mm: make slab_common.c explicitly non-modular
In-Reply-To: <1440454482-12250-3-git-send-email-paul.gortmaker@windriver.com>
Message-ID: <alpine.DEB.2.11.1508250959200.15945@east.gentwo.org>
References: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com> <1440454482-12250-3-git-send-email-paul.gortmaker@windriver.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 24 Aug 2015, Paul Gortmaker wrote:

> @@ -1113,7 +1113,7 @@ static int __init slab_proc_init(void)
>  						&proc_slabinfo_operations);
>  	return 0;
>  }
> -module_init(slab_proc_init);
> +device_initcall(slab_proc_init);
>  #endif /* CONFIG_SLABINFO */
>
>  static __always_inline void *__do_krealloc(const void *p, size_t new_size,

True memory management is not a module. But its also not a device.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
