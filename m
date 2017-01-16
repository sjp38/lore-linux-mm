Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D4036B0038
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 12:59:51 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id k15so101284332qtg.5
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 09:59:51 -0800 (PST)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id t8si14722707qta.36.2017.01.16.09.59.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 09:59:50 -0800 (PST)
Received: by mail-qt0-x242.google.com with SMTP id n13so15618035qtc.0
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 09:59:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1482725891-10866-1-git-send-email-jaewon31.kim@samsung.com>
References: <CGME20161226041809epcas5p1981244de55764c10f1a80d80346f3664@epcas5p1.samsung.com>
 <1482725891-10866-1-git-send-email-jaewon31.kim@samsung.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Mon, 16 Jan 2017 19:59:50 +0200
Message-ID: <CAHp75VfO6POaH+AsoS9kU1y+CEKwuJ0FNSB8Bg866X3iXS9DRA@mail.gmail.com>
Subject: Re: [PATCH] lib: bitmap: introduce bitmap_find_next_zero_area_and_size
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, labbott@redhat.com, Michal Nazarewicz <mina86@mina86.com>, m.szyprowski@samsung.com, gregory.0xf0@gmail.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, akinobu.mita@gmail.com, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, jaewon31.kim@gmail.com

On Mon, Dec 26, 2016 at 6:18 AM, Jaewon Kim <jaewon31.kim@samsung.com> wrote:
> There was no bitmap API which returns both next zero index and size of zeros
> from that index.
>
> This is helpful to look fragmentation. This is an test code to look size of zeros.
> Test result is '10+9+994=>1013 found of total: 1024'
>
> unsigned long search_idx, found_idx, nr_found_tot;
> unsigned long bitmap_max;
> unsigned int nr_found;
> unsigned long *bitmap;
>
> search_idx = nr_found_tot = 0;
> bitmap_max = 1024;
> bitmap = kzalloc(BITS_TO_LONGS(bitmap_max) * sizeof(long),
>                  GFP_KERNEL);
>
> /* test bitmap_set offset, count */
> bitmap_set(bitmap, 10, 1);
> bitmap_set(bitmap, 20, 10);
>
> for (;;) {
>         found_idx = bitmap_find_next_zero_area_and_size(bitmap,
>                                 bitmap_max, search_idx, &nr_found);
>         if (found_idx >= bitmap_max)
>                 break;
>         if (nr_found_tot == 0)
>                 printk("%u", nr_found);
>         else
>                 printk("+%u", nr_found);
>         nr_found_tot += nr_found;
>         search_idx = found_idx + nr_found;
> }
> printk("=>%lu found of total: %lu\n", nr_found_tot, bitmap_max);

Tests should be added to corresponding test module. See lib/*test*
files for details.

-- 
With Best Regards,
Andy Shevchenko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
