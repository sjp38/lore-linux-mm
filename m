Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6172B6B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 15:05:57 -0400 (EDT)
Received: by wikq8 with SMTP id q8so89648296wik.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 12:05:56 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id by5si6799549wib.116.2015.10.23.12.05.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 12:05:56 -0700 (PDT)
Received: by wicfx6 with SMTP id fx6so43633471wic.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 12:05:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1445626439-8424-1-git-send-email-toshi.kani@hpe.com>
References: <1445626439-8424-1-git-send-email-toshi.kani@hpe.com>
Date: Fri, 23 Oct 2015 12:05:56 -0700
Message-ID: <CAPcyv4gj-UXUB52B6sU37w4qtdND9zbxijVQqGg9Kxa9=RNOvg@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] Allow EINJ to inject memory error to NVDIMM
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux ACPI <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Oct 23, 2015 at 11:53 AM, Toshi Kani <toshi.kani@hpe.com> wrote:
> This patch-set extends the EINJ driver to allow injecting a memory
> error to NVDIMM.  It first extends iomem resource interface to support
> checking a NVDIMM region.
>
> Patch 1/3 changes region_intersects() to accept non-RAM regions, and
> adds region_intersects_ram().
>
> Patch 2/3 adds region_intersects_pmem() to check a NVDIMM region.
>
> Patch 3/3 changes the EINJ driver to allow injecting a memory error
> to NVDIMM.
>
> ---
> v2:
>  - Change the EINJ driver to call region_intersects_ram() for checking
>    RAM with a specified size. (Dan Williams)
>  - Add export to region_intersects_ram().
>
> ---

For the series:

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
