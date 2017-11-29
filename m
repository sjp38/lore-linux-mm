Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0B10D6B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 16:30:25 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id k186so4214322ith.1
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 13:30:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c95sor1363527iod.126.2017.11.29.13.30.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 13:30:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171129153437epcms5p64b04efa370cc42bb0f9e5677e298704e@epcms5p6>
References: <20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
 <20171120154648.6c2f96804c4c1668bd8d572a@linux-foundation.org>
 <CGME20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p6>
 <CALZtONA1R8HyODqUP8Z-0yxvRAsV=Zo8OD2PQT3HwWWmqE6Hig@mail.gmail.com> <20171129153437epcms5p64b04efa370cc42bb0f9e5677e298704e@epcms5p6>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 29 Nov 2017 16:29:42 -0500
Message-ID: <CALZtONBr8PcZgvSkNnnTGgu0qoj-Cwc=-mALKNGof4aQ4399ow@mail.gmail.com>
Subject: Re: [PATCH] zswap: Update with same-value filled page feature
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srividya Desireddy <srividya.dr@samsung.com>
Cc: "sjenning@redhat.com" <sjenning@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, RAJIB BASU <rajib.basu@samsung.com>, Srikanth Mandalapu <srikanth.m@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

On Wed, Nov 29, 2017 at 10:34 AM, Srividya Desireddy
<srividya.dr@samsung.com> wrote:
> From: Srividya Desireddy <srividya.dr@samsung.com>
> Date: Wed, 29 Nov 2017 20:23:15 +0530
> Subject: [PATCH] zswap: Update with same-value filled page feature
>
> Updated zswap document with details on same-value filled
> pages identification feature.
> The usage of zswap.same_filled_pages_enabled module parameter
> is explained.
>
> Signed-off-by: Srividya Desireddy <srividya.dr@samsung.com>
> ---
>  Documentation/vm/zswap.txt | 22 +++++++++++++++++++++-
>  1 file changed, 21 insertions(+), 1 deletion(-)
>
> diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
> index 89fff7d..cc015b5 100644
> --- a/Documentation/vm/zswap.txt
> +++ b/Documentation/vm/zswap.txt
> @@ -98,5 +98,25 @@ request is made for a page in an old zpool, it is uncompressed using its
>  original compressor.  Once all pages are removed from an old zpool, the zpool
>  and its compressor are freed.
>
> +Some of the pages in zswap are same-value filled pages (i.e. contents of the
> +page have same value or repetitive pattern). These pages include zero-filled
> +pages and they are handled differently. During store operation, a page is
> +checked if it is a same-value filled page before compressing it. If true, the
> +compressed length of the page is set to zero and the pattern or same-filled
> +value is stored.
> +
> +Same-value filled pages identification feature is enabled by default and can be
> +disabled at boot time by setting the "same_filled_pages_enabled" attribute to 0,
> +e.g. zswap.same_filled_pages_enabled=0. It can also be enabled and disabled at
> +runtime using the sysfs "same_filled_pages_enabled" attribute, e.g.
> +
> +echo 1 > /sys/module/zswap/parameters/same_filled_pages_enabled
> +
> +When zswap same-filled page identification is disabled at runtime, it will stop
> +checking for the same-value filled pages during store operation. However, the
> +existing pages which are marked as same-value filled pages will be loaded or
> +invalidated.

On first read I thought you were saying existing pages were
immediately loaded or invalidated, which of course is not the case.
Can you update the sentence to clarify existing pages are not modified
by disabling the param, like:

"However, the existing pages which are marked as same-value filled
pages remain stored unchanged until they are either loaded or
invalidated."

except for that the doc update looks good.

> +
>  A debugfs interface is provided for various statistic about pool size, number
> -of pages stored, and various counters for the reasons pages are rejected.
> +of pages stored, same-value filled pages and various counters for the reasons
> +pages are rejected.
> --
> 2.7.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
