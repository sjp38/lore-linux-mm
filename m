Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB8E6B0070
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 18:12:45 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so44370821pac.13
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 15:12:44 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i9si11683560pdn.55.2015.01.29.15.12.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jan 2015 15:12:44 -0800 (PST)
Date: Thu, 29 Jan 2015 15:12:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 06/17] mm: slub: introduce
 metadata_access_enable()/metadata_access_disable()
Message-Id: <20150129151243.fd76aca21757b1ca5b62163e@linux-foundation.org>
In-Reply-To: <1422544321-24232-7-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-7-git-send-email-a.ryabinin@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Thu, 29 Jan 2015 18:11:50 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

> Wrap access to object's metadata in external functions with
> metadata_access_enable()/metadata_access_disable() function calls.
> 
> This hooks separates payload accesses from metadata accesses
> which might be useful for different checkers (e.g. KASan).
> 
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -467,13 +467,23 @@ static int slub_debug;
>  static char *slub_debug_slabs;
>  static int disable_higher_order_debug;
>  
> +static inline void metadata_access_enable(void)
> +{
> +}
> +
> +static inline void metadata_access_disable(void)
> +{
> +}

Some code comments here would be useful.  What they do, why they exist,
etc.  The next patch fills them in with
kasan_disable_local/kasan_enable_local but that doesn't help the reader
to understand what's going on.  The fact that
kasan_disable_local/kasan_enable_local are also undocumented doesn't
help.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
