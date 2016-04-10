Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 90AA66B0005
	for <linux-mm@kvack.org>; Sat,  9 Apr 2016 21:42:22 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id ot11so14420496pab.1
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 18:42:22 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id 18si9994190pfs.117.2016.04.09.18.42.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Apr 2016 18:42:21 -0700 (PDT)
Received: by mail-pa0-x230.google.com with SMTP id bx7so81776572pad.3
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 18:42:21 -0700 (PDT)
Date: Sun, 10 Apr 2016 11:40:06 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v2 2/2] lib: lz4: cleanup unaligned access efficiency
 detection
Message-ID: <20160410024006.GA695@swordfish>
References: <1460235935-1003-1-git-send-email-rsalvaterra@gmail.com>
 <1460235935-1003-3-git-send-email-rsalvaterra@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460235935-1003-3-git-send-email-rsalvaterra@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Salvaterra <rsalvaterra@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, sergey.senozhatsky@gmail.com, sergey.senozhatsky.work@gmail.com, gregkh@linuxfoundation.org, eunb.song@samsung.com, minchan@kernel.org, chanho.min@lge.com, kyungsik.lee@lge.com

On (04/09/16 22:05), Rui Salvaterra wrote:
> These identifiers are bogus. The interested architectures should define
> HAVE_EFFICIENT_UNALIGNED_ACCESS whenever relevant to do so. If this
> isn't true for some arch, it should be fixed in the arch definition.

yes, besides ARM_EFFICIENT_UNALIGNED_ACCESS exists only in lib/lz4/lz4defs.h

> Signed-off-by: Rui Salvaterra <rsalvaterra@gmail.com>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>


	-ss

> ---
>  lib/lz4/lz4defs.h | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/lib/lz4/lz4defs.h b/lib/lz4/lz4defs.h
> index 0710a62..c79d7ea 100644
> --- a/lib/lz4/lz4defs.h
> +++ b/lib/lz4/lz4defs.h
> @@ -24,9 +24,7 @@
>  typedef struct _U16_S { u16 v; } U16_S;
>  typedef struct _U32_S { u32 v; } U32_S;
>  typedef struct _U64_S { u64 v; } U64_S;
> -#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)		\
> -	|| defined(CONFIG_ARM) && __LINUX_ARM_ARCH__ >= 6	\
> -	&& defined(ARM_EFFICIENT_UNALIGNED_ACCESS)
> +#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
>  
>  #define A16(x) (((U16_S *)(x))->v)
>  #define A32(x) (((U32_S *)(x))->v)
> -- 
> 2.7.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
