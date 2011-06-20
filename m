Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9D53D9000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 10:45:43 -0400 (EDT)
Received: by gxk23 with SMTP id 23so593998gxk.14
        for <linux-mm@kvack.org>; Mon, 20 Jun 2011 07:45:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1308556213-24970-8-git-send-email-m.szyprowski@samsung.com>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
	<1308556213-24970-8-git-send-email-m.szyprowski@samsung.com>
Date: Mon, 20 Jun 2011 23:45:41 +0900
Message-ID: <BANLkTikFdrOuXsLCfvyA_V+p7S_fd72dyQ@mail.gmail.com>
Subject: Re: [PATCH 7/8] common: dma-mapping: change alloc/free_coherent
 method to more generic alloc/free_attrs
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

> =A0struct dma_map_ops {
> - =A0 =A0 =A0 void* (*alloc_coherent)(struct device *dev, size_t size,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_addr_t =
*dma_handle, gfp_t gfp);
> - =A0 =A0 =A0 void (*free_coherent)(struct device *dev, size_t size,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *vaddr, dm=
a_addr_t dma_handle);
> + =A0 =A0 =A0 void* (*alloc)(struct device *dev, size_t size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_addr_t =
*dma_handle, gfp_t gfp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct dma_=
attrs *attrs);
> + =A0 =A0 =A0 void (*free)(struct device *dev, size_t size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *vaddr, dm=
a_addr_t dma_handle,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct dma_attr=
s *attrs);
> + =A0 =A0 =A0 int (*mmap)(struct device *, struct vm_area_struct *,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *, dma_addr_t, siz=
e_t, struct dma_attrs *attrs);
> +
> =A0 =A0 =A0 =A0dma_addr_t (*map_page)(struct device *dev, struct page *pa=
ge,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long=
 offset, size_t size,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum dma_data=
_direction dir,

I still don't agree with your idea that change alloc_coherent() with alloc(=
).
As I said before, we actually do not need dma_alloc_writecombine() anymore
because it is not different from dma_alloc_coherent() in ARM.
Most of other architectures do not have dma_alloc_writecombine().
If you want dma_alloc_coherent() to allocate user virtual address,
I believe that it is also available with mmap() you introduced.

Regards,
Cho KyongHo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
