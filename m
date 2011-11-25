Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 41E186B0073
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 11:15:18 -0500 (EST)
Received: by ghrr17 with SMTP id r17so4775794ghr.14
        for <linux-mm@kvack.org>; Fri, 25 Nov 2011 08:15:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1318325033-32688-2-git-send-email-sumit.semwal@ti.com>
References: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
	<1318325033-32688-2-git-send-email-sumit.semwal@ti.com>
Date: Fri, 25 Nov 2011 16:15:11 +0000
Message-ID: <CAPM=9tzjO7poyz_uYFFgONxzuTB86kKej8f2XBDHLGdUPZHvjg@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [RFC 1/2] dma-buf: Introduce dma buffer sharing mechanism
From: Dave Airlie <airlied@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, daniel@ffwll.ch

> +struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct device *dev)
> +{
> + =A0 =A0 =A0 struct dma_buf_attachment *attach;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 BUG_ON(!dmabuf || !dev);
> +
> + =A0 =A0 =A0 mutex_lock(&dmabuf->lock);
> +
> + =A0 =A0 =A0 attach =3D kzalloc(sizeof(struct dma_buf_attachment), GFP_K=
ERNEL);
> + =A0 =A0 =A0 if (attach =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_alloc;
> +
> + =A0 =A0 =A0 attach->dev =3D dev;
> + =A0 =A0 =A0 if (dmabuf->ops->attach) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D dmabuf->ops->attach(dmabuf, dev, at=
tach);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_attach;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 list_add(&attach->node, &dmabuf->attachments);
> +

I would assume at some point this needed at
attach->dmabuf =3D dmabuf;
added.

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
