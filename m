Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5173F6B0038
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 11:31:26 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x61so9237334wrb.8
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 08:31:26 -0700 (PDT)
Received: from mail-wr0-x22b.google.com (mail-wr0-x22b.google.com. [2a00:1450:400c:c0c::22b])
        by mx.google.com with ESMTPS id u64si3398145wmd.70.2017.04.21.08.31.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 08:31:24 -0700 (PDT)
Received: by mail-wr0-x22b.google.com with SMTP id z109so57024243wrb.1
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 08:31:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1492540034-5466-1-git-send-email-labbott@redhat.com>
References: <1492540034-5466-1-git-send-email-labbott@redhat.com>
From: Sumit Semwal <sumit.semwal@linaro.org>
Date: Fri, 21 Apr 2017 21:01:03 +0530
Message-ID: <CAO_48GGoyD++0GgRbP8HXXDwEX8cwNvWRh+61WZg03vhEetCPQ@mail.gmail.com>
Subject: Re: [PATCHv4 00/12] Ion cleanup in preparation for moving out of staging
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Riley Andrews <riandrews@android.com>, =?UTF-8?B?QXJ2ZSBIau+/vW5uZXbvv71n?= <arve@android.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rom Lemarchand <romlem@google.com>, devel@driverdev.osuosl.org, LKML <linux-kernel@vger.kernel.org>, Linaro MM SIG <linaro-mm-sig@lists.linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, DRI mailing list <dri-devel@lists.freedesktop.org>, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>

Hi Laura,

Thanks much for this series!

On 18 April 2017 at 23:57, Laura Abbott <labbott@redhat.com> wrote:
> Hi,
>
> This is v4 of the series to cleanup to Ion. Greg took some of the patches
> that weren't CMA related already. There was a minor bisectability problem
> with the CMA APIs so this is a new version to address that. I also
> addressed some minor comments on the patch to collapse header files.

For the series, please feel free to apply my
Acked-by: Sumit Semwal <sumit.semwal@linaro.org>

>
> Thanks,
> Laura
>
> Laura Abbott (12):
>   cma: Store a name in the cma structure
>   cma: Introduce cma_for_each_area
>   staging: android: ion: Use CMA APIs directly
>   staging: android: ion: Stop butchering the DMA address
>   staging: android: ion: Break the ABI in the name of forward progress
>   staging: android: ion: Get rid of ion_phys_addr_t
>   staging: android: ion: Collapse internal header files
>   staging: android: ion: Rework heap registration/enumeration
>   staging: android: ion: Drop ion_map_kernel interface
>   staging: android: ion: Remove ion_handle and ion_client
>   staging: android: ion: Set query return value
>   staging/android: Update Ion TODO list
>
>  arch/powerpc/kvm/book3s_hv_builtin.c            |   3 +-
>  drivers/base/dma-contiguous.c                   |   5 +-
>  drivers/staging/android/TODO                    |  21 +-
>  drivers/staging/android/ion/Kconfig             |  32 +
>  drivers/staging/android/ion/Makefile            |  11 +-
>  drivers/staging/android/ion/compat_ion.c        | 152 -----
>  drivers/staging/android/ion/compat_ion.h        |  29 -
>  drivers/staging/android/ion/ion-ioctl.c         |  55 +-
>  drivers/staging/android/ion/ion.c               | 812 ++----------------=
------
>  drivers/staging/android/ion/ion.h               | 386 ++++++++---
>  drivers/staging/android/ion/ion_carveout_heap.c |  21 +-
>  drivers/staging/android/ion/ion_chunk_heap.c    |  16 +-
>  drivers/staging/android/ion/ion_cma_heap.c      | 120 ++--
>  drivers/staging/android/ion/ion_heap.c          |  68 --
>  drivers/staging/android/ion/ion_page_pool.c     |   3 +-
>  drivers/staging/android/ion/ion_priv.h          | 453 -------------
>  drivers/staging/android/ion/ion_system_heap.c   |  39 +-
>  drivers/staging/android/uapi/ion.h              |  36 +-
>  include/linux/cma.h                             |   6 +-
>  mm/cma.c                                        |  31 +-
>  mm/cma.h                                        |   1 +
>  mm/cma_debug.c                                  |   2 +-
>  22 files changed, 524 insertions(+), 1778 deletions(-)
>  delete mode 100644 drivers/staging/android/ion/compat_ion.c
>  delete mode 100644 drivers/staging/android/ion/compat_ion.h
>  delete mode 100644 drivers/staging/android/ion/ion_priv.h
>
> --
> 2.7.4
>



--=20
Thanks and regards,

Sumit Semwal
Linaro Mobile Group - Kernel Team Lead
Linaro.org =E2=94=82 Open source software for ARM SoCs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
