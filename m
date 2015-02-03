Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9D8386B0071
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 16:45:43 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id z12so47145195wgg.3
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 13:45:43 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id mw9si331779wib.48.2015.02.03.13.45.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Feb 2015 13:45:42 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-mm-sig] [RFCv3 2/2] dma-buf: add helpers for sharing attacher constraints with dma-parms
Date: Tue, 03 Feb 2015 22:44:53 +0100
Message-ID: <19028710.jGRCggLuRk@wuerfel>
In-Reply-To: <CAF6AEGuf6XBe3YOjhtbBcSyqJrkZ7sNMfc83hZdnKsE3P=vSuw@mail.gmail.com>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org> <20150203165829.GW8656@n2100.arm.linux.org.uk> <CAF6AEGuf6XBe3YOjhtbBcSyqJrkZ7sNMfc83hZdnKsE3P=vSuw@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linaro-kernel@lists.linaro.org
Cc: Rob Clark <robdclark@gmail.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tomasz Stanislawski <stanislawski.tomasz@googlemail.com>, LKML <linux-kernel@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Daniel Vetter <daniel@ffwll.ch>, Robin Murphy <robin.murphy@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

On Tuesday 03 February 2015 12:35:34 Rob Clark wrote:
> 
> I can't think of cases outside of GPU's..  if it were more common I'd
> be in favor of teaching dma api about multiple contexts, but right now
> I think that would just amount to forcing a lot of churn on everyone
> else for the benefit of GPU's.

We have a couple of users of the iommu API at the moment outside of
GPUs:

* drivers/media/platform/omap3isp/isp.c
* drivers/remoteproc/remoteproc_core.c
* drivers/infiniband/hw/usnic/usnic_uiom.c
* drivers/vfio/

I assume we will see a few more over time. The vfio case is the most
important one here, since that is what the iommu API was designed for.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
