Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 380506B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 15:29:29 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id c26-v6so3572101uam.19
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 12:29:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a131-v6sor7514675vki.204.2018.06.07.12.29.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Jun 2018 12:29:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180607145720.22590-2-willy@infradead.org>
References: <20180607145720.22590-1-willy@infradead.org> <20180607145720.22590-2-willy@infradead.org>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 7 Jun 2018 12:29:26 -0700
Message-ID: <CAGXu5jJt_Y5KJwCKVPpTFOBt36aDAG9TqbB2bWAdu+2oGV5cZg@mail.gmail.com>
Subject: Re: [PATCH 1/6] Convert virtio_console to struct_size
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Thu, Jun 7, 2018 at 7:57 AM, Matthew Wilcox <willy@infradead.org> wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
>
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  drivers/char/virtio_console.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/char/virtio_console.c b/drivers/char/virtio_console.c
> index 21085515814f..4bf7c06c2343 100644
> --- a/drivers/char/virtio_console.c
> +++ b/drivers/char/virtio_console.c
> @@ -433,8 +433,7 @@ static struct port_buffer *alloc_buf(struct virtio_device *vdev, size_t buf_size
>          * Allocate buffer and the sg list. The sg list array is allocated
>          * directly after the port_buffer struct.
>          */
> -       buf = kmalloc(sizeof(*buf) + sizeof(struct scatterlist) * pages,
> -                     GFP_KERNEL);
> +       buf = kmalloc(struct_size(buf, sg, pages), GFP_KERNEL);
>         if (!buf)
>                 goto fail;

I feel like this one should have been caught by Coccinelle... maybe
the transitive case got missed? Regardless, I'll figure out how to
improve the script and/or take these.

Thanks!

-Kees

-- 
Kees Cook
Pixel Security
