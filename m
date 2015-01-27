Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0676B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 02:04:35 -0500 (EST)
Received: by mail-oi0-f54.google.com with SMTP id v63so11033711oia.13
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 23:04:35 -0800 (PST)
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com. [209.85.214.178])
        by mx.google.com with ESMTPS id o184si201155oif.15.2015.01.26.23.04.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 23:04:34 -0800 (PST)
Received: by mail-ob0-f178.google.com with SMTP id nt9so11990017obb.9
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 23:04:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150121173128.GV26493@n2100.arm.linux.org.uk>
References: <1421813807-9178-1-git-send-email-sumit.semwal@linaro.org>
 <1421813807-9178-3-git-send-email-sumit.semwal@linaro.org> <20150121173128.GV26493@n2100.arm.linux.org.uk>
From: Sumit Semwal <sumit.semwal@linaro.org>
Date: Tue, 27 Jan 2015 12:34:13 +0530
Message-ID: <CAO_48GE4XQm+Fd9JUGzyw9fsFDSo6+fRY79vwS=Yjcw5GLZAJg@mail.gmail.com>
Subject: Re: [RFCv2 2/2] dma-buf: add helpers for sharing attacher constraints
 with dma-parms
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Linaro MM SIG Mailman List <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Rob Clark <robdclark@gmail.com>, Daniel Vetter <daniel@ffwll.ch>, Marek Szyprowski <m.szyprowski@samsung.com>

Hi Russell!

On 21 January 2015 at 23:01, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Wed, Jan 21, 2015 at 09:46:47AM +0530, Sumit Semwal wrote:
>> +static int calc_constraints(struct device *dev,
>> +                         struct dma_buf_constraints *calc_cons)
>> +{
>> +     struct dma_buf_constraints cons =3D *calc_cons;
>> +
>> +     cons.dma_mask &=3D dma_get_mask(dev);
>
> I don't think this makes much sense when you consider that the DMA
> infrastructure supports buses with offsets.  The DMA mask is th
> upper limit of the _bus_ specific address, it is not a mask per-se.
>
> What this means is that &=3D is not the right operation.  Moreover,
> simply comparing masks which could be from devices on unrelated
> buses doesn't make sense either.
>
> However, that said, I don't have an answer for what you want to
> achieve here.

Thanks for your comments! I suppose in that case, I will leave out the
*dma_masks from this constraints information for now; we can re-visit
it when a specific use case really needs information about the
dma-masks of the attached devices.

I will post an updated patch-set soon.
>
> --
> FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
> according to speedtest.net.



--=20
Thanks and regards,

Sumit Semwal
Kernel Team Lead - Linaro Mobile Group
Linaro.org =E2=94=82 Open source software for ARM SoCs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
