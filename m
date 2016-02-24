Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 11AF96B0009
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 09:22:40 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id c200so271987668wme.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 06:22:40 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id z2si3844843wjz.132.2016.02.24.06.22.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 06:22:38 -0800 (PST)
Received: by mail-wm0-x22c.google.com with SMTP id g62so6822240wme.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 06:22:38 -0800 (PST)
Subject: Re: [PATCHv2 1/4] slub: Drop lock at the end of free_debug_processing
References: <1455561864-4217-1-git-send-email-labbott@fedoraproject.org>
 <1455561864-4217-2-git-send-email-labbott@fedoraproject.org>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <56CDBCAB.9040001@redhat.com>
Date: Wed, 24 Feb 2016 15:22:35 +0100
MIME-Version: 1.0
In-Reply-To: <1455561864-4217-2-git-send-email-labbott@fedoraproject.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>



On 15/02/2016 19:44, Laura Abbott wrote:
> -static inline struct kmem_cache_node *free_debug_processing(
> +static inline int free_debug_processing(
>  	struct kmem_cache *s, struct page *page,
>  	void *head, void *tail, int bulk_cnt,
>  	unsigned long addr, unsigned long *flags) { return NULL; }

I think this has a leftover flags argument.

Paolo

> @@ -2648,8 +2646,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
>  	stat(s, FREE_SLOWPATH);
>  
>  	if (kmem_cache_debug(s) &&
> -	    !(n = free_debug_processing(s, page, head, tail, cnt,
> -					addr, &flags)))
> +	    !free_debug_processing(s, page, head, tail, cnt, addr))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
