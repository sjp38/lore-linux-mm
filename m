Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA6506B026E
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 12:06:59 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 79so2222591iou.19
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 09:06:59 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id u203si2832703iod.284.2018.01.11.09.06.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jan 2018 09:06:58 -0800 (PST)
Date: Thu, 11 Jan 2018 11:06:56 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 02/38] usercopy: Enhance and rename report_usercopy()
In-Reply-To: <1515636190-24061-3-git-send-email-keescook@chromium.org>
Message-ID: <alpine.DEB.2.20.1801111101420.6443@nuc-kabylake>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org> <1515636190-24061-3-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On Wed, 10 Jan 2018, Kees Cook wrote:

> diff --git a/mm/slab.h b/mm/slab.h
> index ad657ffa44e5..7d29e69ac310 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -526,4 +526,10 @@ static inline int cache_random_seq_create(struct kmem_cache *cachep,
>  static inline void cache_random_seq_destroy(struct kmem_cache *cachep) { }
>  #endif /* CONFIG_SLAB_FREELIST_RANDOM */
>
> +#ifdef CONFIG_HARDENED_USERCOPY
> +void __noreturn usercopy_abort(const char *name, const char *detail,
> +			       bool to_user, unsigned long offset,
> +			       unsigned long len);
> +#endif
> +
>  #endif /* MM_SLAB_H */

This code has nothing to do with slab allocation. Move it into
include/linux/uaccess.h where the other user space access definitions are?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
