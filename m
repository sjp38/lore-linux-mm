Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0058F9000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 10:37:55 -0400 (EDT)
Received: by yxn22 with SMTP id 22so662478yxn.14
        for <linux-mm@kvack.org>; Mon, 20 Jun 2011 07:37:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308556213-24970-5-git-send-email-m.szyprowski@samsung.com>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
	<1308556213-24970-5-git-send-email-m.szyprowski@samsung.com>
Date: Mon, 20 Jun 2011 23:37:53 +0900
Message-ID: <BANLkTimwo9bMCevBRxfSZJBrkjDpdihtKw@mail.gmail.com>
Subject: Re: [PATCH 4/8] ARM: dma-mapping: implement dma sg methods on top of
 generic dma ops
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>

Hi.

On Mon, Jun 20, 2011 at 4:50 PM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
> -extern int arm_dma_map_sg(struct device *, struct scatterlist *, int,
> +extern int generic_dma_map_sg(struct device *, struct scatterlist *, int=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum dma_data_direction, struct dma_attrs =
*attrs);
> -extern void arm_dma_unmap_sg(struct device *, struct scatterlist *, int,
> +extern void generic_dma_unmap_sg(struct device *, struct scatterlist *, =
int,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum dma_data_direction, struct dma_attrs =
*attrs);
> -extern void arm_dma_sync_sg_for_cpu(struct device *, struct scatterlist =
*, int,
> +extern void generic_dma_sync_sg_for_cpu(struct device *, struct scatterl=
ist *, int,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum dma_data_direction);
> -extern void arm_dma_sync_sg_for_device(struct device *, struct scatterli=
st *, int,
> +extern void generic_dma_sync_sg_for_device(struct device *, struct scatt=
erlist *, int,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum dma_data_direction);
>

I don't understand why you changed arm_dma_*() with generic_dma_*()
even though they're functionality is not changed
and they are still specific to ARM.
They look like that they are generic in the kernel code.

Regards,
Cho KyongHo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
