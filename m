Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1EF6B5800
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 06:44:54 -0500 (EST)
Received: by mail-vs1-f71.google.com with SMTP id t136so2338080vsc.12
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 03:44:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x62sor2490413vsa.96.2018.11.30.03.44.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Nov 2018 03:44:53 -0800 (PST)
MIME-Version: 1.0
References: <CALjTZvZzHSZ=s0W0Pd-MVd7OA0hYxu0LzsZ+GxYybXKoUQQR6Q@mail.gmail.com>
 <20181130103222.GA23393@lst.de>
In-Reply-To: <20181130103222.GA23393@lst.de>
From: Rui Salvaterra <rsalvaterra@gmail.com>
Date: Fri, 30 Nov 2018 11:44:41 +0000
Message-ID: <CALjTZvZsk0qA+Yxu7S+8pfa5y6rpihnThrHiAKkZMWsdyC-tVg@mail.gmail.com>
Subject: Re: use generic DMA mapping code in powerpc V4
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hch@lst.de
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Fri, 30 Nov 2018 at 10:32, Christoph Hellwig <hch@lst.de> wrote:
>
> Hi Rui,
>
> can you check if the patch below fixes the issue for you?
>
> diff --git a/arch/powerpc/sysdev/dart_iommu.c b/arch/powerpc/sysdev/dart_iommu.c
> index 2e24fc87ed84..809797dbe169 100644
> --- a/arch/powerpc/sysdev/dart_iommu.c
> +++ b/arch/powerpc/sysdev/dart_iommu.c
> @@ -392,7 +392,9 @@ static void pci_dma_dev_setup_dart(struct pci_dev *dev)
>
>  static bool iommu_bypass_supported_dart(struct pci_dev *dev, u64 mask)
>  {
> -       return dart_is_u4 && dart_device_on_pcie(&dev->dev);
> +       return dart_is_u4 &&
> +               dart_device_on_pcie(&dev->dev) &&
> +               mask >= DMA_BIT_MASK(40);
>  }
>
>  void __init iommu_init_early_dart(struct pci_controller_ops *controller_ops)

Hi, Christoph,

Thanks for the quick response! I applied it on top of your
powerpc-dma.4 branch and retested.
I'm not seeing nouveau complaining anymore (I'm not using X11 or any
DE, though).
In any case and FWIW, this series is

Tested-by: Rui Salvaterra <rsalvaterra@gmail.com>

Thanks,
Rui
