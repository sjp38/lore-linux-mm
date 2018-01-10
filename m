Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 09C376B025F
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 13:28:29 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id d62so345810iof.0
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 10:28:29 -0800 (PST)
Received: from resqmta-po-04v.sys.comcast.net (resqmta-po-04v.sys.comcast.net. [2001:558:fe16:19:96:114:154:163])
        by mx.google.com with ESMTPS id p2si1076470ite.121.2018.01.10.10.28.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 10:28:27 -0800 (PST)
Date: Wed, 10 Jan 2018 12:28:23 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 04/36] usercopy: Prepare for usercopy whitelisting
In-Reply-To: <1515531365-37423-5-git-send-email-keescook@chromium.org>
Message-ID: <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org> <1515531365-37423-5-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

On Tue, 9 Jan 2018, Kees Cook wrote:

> +struct kmem_cache *kmem_cache_create_usercopy(const char *name,
> +			size_t size, size_t align, slab_flags_t flags,
> +			size_t useroffset, size_t usersize,
> +			void (*ctor)(void *));

Hmmm... At some point we should switch kmem_cache_create to pass a struct
containing all the parameters. Otherwise the API will blow up with
additional functions.

> index 2181719fd907..70c4b4bb4d1f 100644
> --- a/include/linux/stddef.h
> +++ b/include/linux/stddef.h
> @@ -19,6 +19,8 @@ enum {
>  #define offsetof(TYPE, MEMBER)	((size_t)&((TYPE *)0)->MEMBER)
>  #endif
>
> +#define sizeof_field(structure, field) sizeof((((structure *)0)->field))
> +
>  /**
>   * offsetofend(TYPE, MEMBER)
>   *

Have a separate patch for adding this functionality? Its not a slab
maintainer
file.

Rest looks ok.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
