Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 905FBC48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 17:18:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55F28208E3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 17:18:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55F28208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E76D06B0003; Wed, 26 Jun 2019 13:18:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E27348E0003; Wed, 26 Jun 2019 13:18:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEECE8E0002; Wed, 26 Jun 2019 13:18:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7DCE46B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 13:18:28 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c27so4043095edn.8
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 10:18:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nHeSEkJXIvoqOJZ+5cOPpc2ISousIbqPGmXMcAzA6Lk=;
        b=F7CHHO6wiRWRu9wzK6XfHGE3mhBAtHIViTlug7lJUuUk6u6PBe0FqDwxsr3vLq8PFa
         xYsaD7S5Sm5+A5WuFnraaKNo27292vluRt4OyaiM6w9+VtSR4x6Hucqd/w1xovFNTCWt
         HYbY4vMgDcpMUJkuAIQeEy94YJxrae1tLnkeBy78IK/+u+34kRtJ2sc9HYW7OGeeQdrq
         mD8ek4f5CAEUWl0KAOw81iD3vKik2pE0Fd5dK1vmDiMHLrIBKBIFh0c7BYWG5LBcA5kV
         o8RTTov2iYoxsZ++l3NlLDBOtDuzNB4AVF8OeOv4GgrZ8as6Fk3C4ryGmYSOfemP3kP1
         MN6w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWZqh2Jpcf1oMrm/Jew4ohu+wlGpYEgOols9D4Z4CbxhzNzSEuC
	NqD3zqt0ZMlvLHXL6Jg01x86sug8q3B2wnJnK/un0T7tbgvzlPyuBcBG6xs3UOUw0bbZK5d326Q
	NDFbXciWeU0QHNANXEsNII5oBvTpTbtzi0FzlMxzjDoKUVBYOvpv5cHX4fl94buUIMg==
X-Received: by 2002:a17:906:66c2:: with SMTP id k2mr5168227ejp.65.1561569508047;
        Wed, 26 Jun 2019 10:18:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFGg0V5ggS62/EEnK16EKPtsMt6A8tRU0ggJpabDfSGylEEeZYqzqq3V1gLxPk/lbMdhnj
X-Received: by 2002:a17:906:66c2:: with SMTP id k2mr5168158ejp.65.1561569507246;
        Wed, 26 Jun 2019 10:18:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561569507; cv=none;
        d=google.com; s=arc-20160816;
        b=eiX7vMTE56nngj58EaDHVm/RNbY7skDjFsC3wM1keR2nP73Q5IBOwqWA0AB6etUZ8Q
         E4wmKMCLBzxPDWrXmJDq0W9UJVon0sPqeGCDbV/B5oW0qlv1gopChrP5jxp8RTMrNDIQ
         4GVHzd3D3zFJkI02ImXu2R9LU05deSUWv01pa0KuksNJ3Mdv1RZ5idrCT6X8ickHckvp
         EgOLmhSRNddX1qS7jfeX5aFrIlh8ouzPBTJA0IMpMTgF0Yp/3BaoxzZO/vU9LQSfQ17C
         0+yfmqM82ITz4eVogPpz3t1fKL50y6f6zg09+ogk5duNa5b1bOpocZet6XB91vS0yAKs
         MO5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nHeSEkJXIvoqOJZ+5cOPpc2ISousIbqPGmXMcAzA6Lk=;
        b=vu90U8iTNhme0LReD0qnFXjqARdqfedcjLsmvn17mUWUw/Glxk5XP7azxaD81frBtB
         nIr9ZPv4kX4V29eWj9VGkIyMhjiR4huPaFeys94DEHxzgltZQrhaowPjjC2+sFrKoqBV
         eP0XCdF6SfqIDQcE7UhDAtTnPWOkpmv3SQLohbtzt3YoE1yZys8iCjRvELtRwiAhqdVx
         Ic1kDzvzpySREcxgbxO6eADOC1f2u7MuJ6pMNjF9WK+57adLFZ4+5ZGqoO3rq819qI8i
         C3VWaSjd3RxkSVVbVeqonNR6K9yxparXe1BffypnzMALAf1lG4ASr+qfweruZg445rDQ
         1odw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id e1si2862719ejb.15.2019.06.26.10.18.26
        for <linux-mm@kvack.org>;
        Wed, 26 Jun 2019 10:18:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3BC85360;
	Wed, 26 Jun 2019 10:18:26 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 876353F718;
	Wed, 26 Jun 2019 10:18:21 -0700 (PDT)
Date: Wed, 26 Jun 2019 18:18:19 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v18 00/15] arm64: untag user pointers passed to the kernel
Message-ID: <20190626171819.GG29672@arrakis.emea.arm.com>
References: <cover.1561386715.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1561386715.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On Mon, Jun 24, 2019 at 04:32:45PM +0200, Andrey Konovalov wrote:
> Andrey Konovalov (14):
>   arm64: untag user pointers in access_ok and __uaccess_mask_ptr
>   lib: untag user pointers in strn*_user
>   mm: untag user pointers passed to memory syscalls
>   mm: untag user pointers in mm/gup.c
>   mm: untag user pointers in get_vaddr_frames
>   fs/namespace: untag user pointers in copy_mount_options
>   userfaultfd: untag user pointers
>   drm/amdgpu: untag user pointers
>   drm/radeon: untag user pointers in radeon_gem_userptr_ioctl
>   IB/mlx4: untag user pointers in mlx4_get_umem_mr
>   media/v4l2-core: untag user pointers in videobuf_dma_contig_user_get
>   tee/shm: untag user pointers in tee_shm_register
>   vfio/type1: untag user pointers in vaddr_get_pfn
>   selftests, arm64: add a selftest for passing tagged pointers to kernel
> 
> Catalin Marinas (1):
>   arm64: Introduce prctl() options to control the tagged user addresses
>     ABI
> 
>  arch/arm64/Kconfig                            |  9 +++
>  arch/arm64/include/asm/processor.h            |  8 +++
>  arch/arm64/include/asm/thread_info.h          |  1 +
>  arch/arm64/include/asm/uaccess.h              | 12 +++-
>  arch/arm64/kernel/process.c                   | 72 +++++++++++++++++++
>  .../gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c  |  2 +-
>  drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c       |  2 +
>  drivers/gpu/drm/radeon/radeon_gem.c           |  2 +
>  drivers/infiniband/hw/mlx4/mr.c               |  7 +-
>  drivers/media/v4l2-core/videobuf-dma-contig.c |  9 +--
>  drivers/tee/tee_shm.c                         |  1 +
>  drivers/vfio/vfio_iommu_type1.c               |  2 +
>  fs/namespace.c                                |  2 +-
>  fs/userfaultfd.c                              | 22 +++---
>  include/uapi/linux/prctl.h                    |  5 ++
>  kernel/sys.c                                  | 12 ++++
>  lib/strncpy_from_user.c                       |  3 +-
>  lib/strnlen_user.c                            |  3 +-
>  mm/frame_vector.c                             |  2 +
>  mm/gup.c                                      |  4 ++
>  mm/madvise.c                                  |  2 +
>  mm/mempolicy.c                                |  3 +
>  mm/migrate.c                                  |  2 +-
>  mm/mincore.c                                  |  2 +
>  mm/mlock.c                                    |  4 ++
>  mm/mprotect.c                                 |  2 +
>  mm/mremap.c                                   |  7 ++
>  mm/msync.c                                    |  2 +
>  tools/testing/selftests/arm64/.gitignore      |  1 +
>  tools/testing/selftests/arm64/Makefile        | 11 +++
>  .../testing/selftests/arm64/run_tags_test.sh  | 12 ++++
>  tools/testing/selftests/arm64/tags_test.c     | 29 ++++++++
>  32 files changed, 232 insertions(+), 25 deletions(-)

It looks like we got to an agreement on how to deal with tagged user
addresses between SPARC ADI and ARM Memory Tagging. If there are no
other objections, what's your preferred way of getting this series into
-next first and then mainline? Are you ok to merge them into the mm
tree?

Thanks.

-- 
Catalin

