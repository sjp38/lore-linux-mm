Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 584256B0255
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 02:07:06 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so7987928igb.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 23:07:06 -0700 (PDT)
Received: from mail-io0-x229.google.com (mail-io0-x229.google.com. [2607:f8b0:4001:c06::229])
        by mx.google.com with ESMTPS id 2si10722828igt.56.2015.09.14.23.07.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 23:07:05 -0700 (PDT)
Received: by iofh134 with SMTP id h134so191028464iof.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 23:07:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1441888128-10897-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1441888128-10897-1-git-send-email-sergey.senozhatsky@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 15 Sep 2015 02:06:26 -0400
Message-ID: <CALZtONCSpXOB+8AZ4eVKfK8DeH0UX=ZuAK4zn8=UpVabP8pdNg@mail.gmail.com>
Subject: Re: [RFC][PATCH] mm: make zbud znd zpool to depend on zswap
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Thu, Sep 10, 2015 at 8:28 AM, Sergey Senozhatsky
<sergey.senozhatsky@gmail.com> wrote:
> There are no zbud and zpool users besides zswap so enabling
> (and building) CONFIG_ZPOOL and CONFIG_ZBUD make sense only
> when CONFIG_ZSWAP is enabled. In other words, make those
> options to depend on CONFIG_ZSWAP.

Let's wait on this until the patches to add zpool support to zram go
one way or the other.  If they don't make it in, I'm fine with this,
and even moving the zpool.h header into mm/ instead of include/linux/

>
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  mm/Kconfig | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 3455a8d..eb48422 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -563,6 +563,7 @@ config ZSWAP
>
>  config ZPOOL
>         tristate "Common API for compressed memory storage"
> +       depends on ZSWAP
>         default n
>         help
>           Compressed memory storage API.  This allows using either zbud or
> @@ -570,6 +571,7 @@ config ZPOOL
>
>  config ZBUD
>         tristate "Low density storage for compressed pages"
> +       depends on ZSWAP
>         default n
>         help
>           A special purpose allocator for storing compressed pages.
> --
> 2.5.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
