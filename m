Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 06B836B025E
	for <linux-mm@kvack.org>; Wed, 25 May 2016 10:39:18 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g64so26636820pfb.2
        for <linux-mm@kvack.org>; Wed, 25 May 2016 07:39:17 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id vy4si13003744pab.231.2016.05.25.07.39.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 07:39:16 -0700 (PDT)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 8CA1420411
	for <linux-mm@kvack.org>; Wed, 25 May 2016 14:39:15 +0000 (UTC)
Received: from mail-yw0-f173.google.com (mail-yw0-f173.google.com [209.85.161.173])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8268E20172
	for <linux-mm@kvack.org>; Wed, 25 May 2016 14:39:14 +0000 (UTC)
Received: by mail-yw0-f173.google.com with SMTP id o16so49256882ywd.2
        for <linux-mm@kvack.org>; Wed, 25 May 2016 07:39:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1464150590-2703-1-git-send-email-jaewon31.kim@samsung.com>
References: <1464150590-2703-1-git-send-email-jaewon31.kim@samsung.com>
From: Rob Herring <robh+dt@kernel.org>
Date: Wed, 25 May 2016 09:38:54 -0500
Message-ID: <CAL_JsqLu+KxXdZseQiRFPr5MG0hSnwnQJpBLg0M5tgO-ap4F=g@mail.gmail.com>
Subject: Re: [RESEND][PATCH] drivers: of: of_reserved_mem: fixup the CMA
 alignment not to affect dma-coherent
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>
Cc: r64343@freescale.com, Marek Szyprowski <m.szyprowski@samsung.com>, Grant Likely <grant.likely@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, jaewon31.kim@gmail.com

On Tue, May 24, 2016 at 11:29 PM, Jaewon Kim <jaewon31.kim@samsung.com> wrote:
> From: Jaewon <jaewon31.kim@samsung.com>
>
> There was an alignment mismatch issue for CMA and it was fixed by
> commit 1cc8e3458b51 ("drivers: of: of_reserved_mem: fixup the alignment with CMA setup").
> However the way of the commit considers not only dma-contiguous(CMA) but also
> dma-coherent which has no that requirement.
>
> This patch checks more to distinguish dma-contiguous(CMA) from dma-coherent.
>
> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>

I suppose this needs to go to stable? If so, adding the stable tag and
kernel version would be nice so I don't have to.

> ---
>  drivers/of/of_reserved_mem.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)

I'm looking for an ack from Marek on this.

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
