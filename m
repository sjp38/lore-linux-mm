Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59A21C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 12:39:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E773E2086A
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 12:39:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E773E2086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49E168E0075; Thu, 21 Feb 2019 07:39:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44D988E0002; Thu, 21 Feb 2019 07:39:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33CE28E0075; Thu, 21 Feb 2019 07:39:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CF1FE8E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 07:39:23 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c18so11247962edt.23
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 04:39:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=0Tf7UxGpQKaru9qXuHwoIsSAb5ie+9cYN6qW7NdBhLk=;
        b=n9dRnUZmTLTmg8ftDSBvu7cRSIbYDrOPjsHF1fexgWv7P44TRSXF180iZlrkAoEs2h
         Zmgn6USzEQM+O0sv0Z0Op1/oEu0m0PfV8vqNAzqTQsKrXnqQSsnnRbDThsKCqCMw9Lp6
         fpOSBvHXEH8edcj/WxFjZ0mh3Kk65eIdqpu6bG74jpIJW+XrGb5Lz/MuvtQgh70O0On0
         E+I58At0Ivdhy40nMfNWjEyGLUyf+g2S+UauRQ95tlXo85m5QxqzMpY/ZEZisx8ZBTKK
         n2KMLr8fYyYhXhBGSRAOyzBialEZbHd22WVPnPC6/I9fPS2Ri1SThNBd+zBsnvQFjbmv
         trPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAubGWQUTlmfVwGoyraT0R8bDE0h4TtlmUbJqeLyGZfuUr5uarbt/
	kwcQ2Uegxtm52vOSiAv2XZnM5Fa/5CwoxgpKfePgF68UZVvMmCidmfPUHVV5E12qwj8W1XhTX8T
	Z/dsLK93usGbYmMX8Ei0GO88Qbnd6Tqq0Gzt57WFyyib4SaIPikod7CE/cnpDWPNv4w==
X-Received: by 2002:a50:f5b5:: with SMTP id u50mr31934903edm.238.1550752763264;
        Thu, 21 Feb 2019 04:39:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYFcwJMp4kZ1H8JokiTvxODyrHHSF6tQzn1ex5QRPKrE84Oac8rk5GkRIFGP3NdI0cKvhws
X-Received: by 2002:a50:f5b5:: with SMTP id u50mr31934839edm.238.1550752762078;
        Thu, 21 Feb 2019 04:39:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550752762; cv=none;
        d=google.com; s=arc-20160816;
        b=Hq4akX9BegpBbBM+qDeXJuih8lwCDrldvVEoEcEBocVeKoGjW3m3qDWuLHZKVCO+bx
         8lh7959CZOAPCTIoybbwP6nwAQG9CsW1B9fwtVobTiEKk6jGZrIS+hQvTdqeWNlqTanY
         XThju20RT3iG+A+CZbrCqtT4ZkTJx8P+biy0emnVzST26LJ/qpkl+S+Fy2n8R6QzRHEi
         RaZurxeDEjPU0VuEyebvyFyRudFNL5YJCx9hTKxFnOrL0nQQrwy4z0PltWGADBNBfmCw
         xBS9qhsYDirFx31zW+iojQy90mIX432lnVLM9gjWMn5rwJPLfLLidpbeFdjqKbTjXYWC
         Ll0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=0Tf7UxGpQKaru9qXuHwoIsSAb5ie+9cYN6qW7NdBhLk=;
        b=Gt5CjjRjFiNbGnCWPGI+fCYmN8jm1H8bSxHwsQu0NnR5fZc+Ckz+70NJ1u/RmCsSVk
         tSPdHLiT88czGA/Nt2ABi9LCVJfQrBc/FJK/TdLZpQ6bZrbtdBMD4aSZJ11C0yxs9ALj
         lVs9oR2PKQ6gopM8F3bXYBLWtrj0ek+jSZ3zlQJ3IU+SZoC6A1b6cNfw9MrGkgJU6jLD
         IQhnJNpyGzLPOsQX6qpMu25yqjnUJKFnHw0C6YuzvnItSMWaKnWaq2j2asBf5pNM+KyN
         lMRq8nXjb8qkqPOISyjDHbcbkXcYGjfWDjji0a0aLc1go3bSme3xWW1Bz9G5QJenNbIG
         M5tA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u5si1714495edc.375.2019.02.21.04.39.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 04:39:22 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 239E1B609;
	Thu, 21 Feb 2019 12:39:21 +0000 (UTC)
Subject: Re: [PATCH 0/6] Improve handling of GFP flags in the CMA allocator
To: Gabriel Krisman Bertazi <krisman@collabora.com>, linux-mm@kvack.org
Cc: labbott@redhat.com, kernel@collabora.com, gael.portay@collabora.com,
 mike.kravetz@oracle.com, m.szyprowski@samsung.com,
 Michal Hocko <mhocko@kernel.org>
References: <20190218210715.1066-1-krisman@collabora.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <64c93a1e-8a8f-56f3-df1a-c0d85ef9f702@suse.cz>
Date: Thu, 21 Feb 2019 13:39:19 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190218210715.1066-1-krisman@collabora.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/18/19 10:07 PM, Gabriel Krisman Bertazi wrote:
> Hi,
> 
> The main goal of this patchset is to solve a deadlock in the CMA
> allocator, which happens because cma_alloc tries to sleep waiting for an
> IO in the GFP_NOIO path.  This issue, which was reported by Gael Portay
> was discussed here:
> 
> https://groups.google.com/a/lists.one-eyed-alien.net/forum/#!topic/usb-storage/BXpAsg-G1us
> 
> My proposed requires reverting the patches that removed the gfp flags
> information from cma_alloc() (patches 1 to 3).  According to the author,
> that parameter was removed because it misleads developers about what
> cma_alloc actually supports. In his specific case he had problems with
> GFP_ZERO.  With that in mind I gave a try at implementing GFP_ZERO in a
> quite trivial way in patch 4.  Finally, patches 5 and 6 attempt to fix
> the issue by avoiding the unecessary serialization done around
> alloc_contig_range.

I haven't checked in detail yet, but for GFP_NOIO, we have
memalloc_noio_save() / memalloc_noio_restore() which adds implicit
GFP_NOIO for the whole call stack. So that could be perhaps used to
avoid adding the gfp flags back to function signatures. Since you are
adding a new test for __GFP_IO in cma_alloc() in patch 6, you would use
e.g. current_gfp_context(GFP_KERNEL) first to add __GFP_NOIO based on
the implicit context. As for the arm64 caller, maybe it already is in
noio context (ideal world), or would add it based on test before calling
dma_alloc_from_contiguous(). There's also some documentation in
Documentation/core-api/gfp_mask-from-fs-io.rst
CCing Michal for opinion since he authored this

> This is my first adventure in the mm subsystem, so I hope I didn't screw
> up something very obvious. I tested this on the workload that was
> deadlocking (arm board, with CMA intensive operations from the GPU and
> USB), as well as some scripting on top of debugfs.  Is there any
> regression test I should be running, which specially applies to the CMA
> code?
> 
> 
> Gabriel Krisman Bertazi (6):
>   Revert "kernel/dma: remove unsupported gfp_mask parameter from
>     dma_alloc_from_contiguous()"
>   Revert "mm/cma: remove unsupported gfp_mask parameter from
>     cma_alloc()"
>   cma: Warn about callers requesting unsupported flags
>   cma: Add support for GFP_ZERO
>   page_isolation: Propagate temporary pageblock isolation error
>   cma: Isolate pageblocks speculatively during allocation
> 
>  arch/arm/mm/dma-mapping.c                  |  5 +--
>  arch/arm64/mm/dma-mapping.c                |  2 +-
>  arch/powerpc/kvm/book3s_hv_builtin.c       |  2 +-
>  arch/xtensa/kernel/pci-dma.c               |  2 +-
>  drivers/iommu/amd_iommu.c                  |  2 +-
>  drivers/iommu/intel-iommu.c                |  3 +-
>  drivers/s390/char/vmcp.c                   |  2 +-
>  drivers/staging/android/ion/ion_cma_heap.c |  2 +-
>  include/linux/cma.h                        |  2 +-
>  include/linux/dma-contiguous.h             |  4 +-
>  kernel/dma/contiguous.c                    |  6 +--
>  kernel/dma/direct.c                        |  3 +-
>  kernel/dma/remap.c                         |  2 +-
>  mm/cma.c                                   | 51 ++++++++++++++++++----
>  mm/cma_debug.c                             |  2 +-
>  mm/page_isolation.c                        | 20 ++++++---
>  16 files changed, 74 insertions(+), 36 deletions(-)
> 

