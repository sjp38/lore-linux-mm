Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 228FD6B0044
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 20:42:04 -0500 (EST)
Date: Tue, 27 Jan 2009 17:41:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mmotm] mm: unify some pmd_*() functions
Message-Id: <20090127174158.519e5abd.akpm@linux-foundation.org>
In-Reply-To: <1232919337-21434-1-git-send-email-righi.andrea@gmail.com>
References: <1232919337-21434-1-git-send-email-righi.andrea@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <righi.andrea@gmail.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Roman Zippel <zippel@linux-m68k.org>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>
List-ID: <linux-mm.kvack.org>

On Sun, 25 Jan 2009 22:35:37 +0100
Andrea Righi <righi.andrea@gmail.com> wrote:

> diff --git a/include/asm-generic/pgtable-nopmd.h b/include/asm-generic/pgtable-nopmd.h
> index a7cdc48..b132d69 100644
> --- a/include/asm-generic/pgtable-nopmd.h
> +++ b/include/asm-generic/pgtable-nopmd.h
> @@ -4,6 +4,7 @@
>  #ifndef __ASSEMBLY__
>  
>  #include <asm-generic/pgtable-nopud.h>
> +#include <asm/bug.h>
>  
>  struct mm_struct;
>  

Why not include the preferred <linux/bug.h>?

> BTW, I only tested this on x86 and x86_64. This needs more testing because it
> touches also a lot of other architectures.

Hopefully Geert, Roman, David and Hirokazu Takata will have time to
help out here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
