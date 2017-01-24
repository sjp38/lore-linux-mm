Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E8F246B0038
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 16:51:19 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id a194so231661195oib.5
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 13:51:19 -0800 (PST)
Received: from mail-ot0-f173.google.com (mail-ot0-f173.google.com. [74.125.82.173])
        by mx.google.com with ESMTPS id l187si8018155oih.131.2017.01.24.13.51.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 13:51:19 -0800 (PST)
Received: by mail-ot0-f173.google.com with SMTP id 73so138300047otj.0
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 13:51:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170124212200.19052-1-ddstreet@ieee.org>
References: <20170124211724.18746-1-ddstreet@ieee.org> <20170124212200.19052-1-ddstreet@ieee.org>
From: Seth Jennings <sjenning@redhat.com>
Date: Tue, 24 Jan 2017 15:51:18 -0600
Message-ID: <CAC8qmcALc_wz3cM2N4VaVTDa+o9wFybfeV5r1tjf1N1pvZ0QMg@mail.gmail.com>
Subject: Re: [PATCHv2] MAINTAINERS: add Dan Streetman to zswap maintainers
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 24, 2017 at 3:22 PM, Dan Streetman <ddstreet@ieee.org> wrote:
>
> Add myself as zswap maintainer.
>
> Cc: Seth Jennings <sjenning@redhat.com>
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>

Acked-by: Seth Jennings <sjenning@redhat.com>

Very yes to this.  I've had almost no kernel time in my new position :(
Dan, if you wanted to add yourself to the zbud maintainers too, feel free!

Thanks,
Seth

>
> ---
> You'd think I could get this simple patch right.  oops!
>
> Since v1: fixed Seth's email in Cc: line
>
> Seth, I'd meant to send this last year, I assume you're still ok
> adding me.  Did you want to stay on as maintainer also?
>
>  MAINTAINERS | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 741f35f..e5575d5 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -13736,6 +13736,7 @@ F:      Documentation/vm/zsmalloc.txt
>
>  ZSWAP COMPRESSED SWAP CACHING
>  M:     Seth Jennings <sjenning@redhat.com>
> +M:     Dan Streetman <ddstreet@ieee.org>
>  L:     linux-mm@kvack.org
>  S:     Maintained
>  F:     mm/zswap.c
> --
> 2.9.3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
