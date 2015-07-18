Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 73D81280344
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 21:23:38 -0400 (EDT)
Received: by widjy10 with SMTP id jy10so53093182wid.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 18:23:38 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id p3si448243wia.63.2015.07.17.18.23.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 18:23:36 -0700 (PDT)
Received: by widjy10 with SMTP id jy10so53092891wid.1
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 18:23:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1437088996-28511-1-git-send-email-toshi.kani@hp.com>
References: <1437088996-28511-1-git-send-email-toshi.kani@hp.com>
Date: Fri, 17 Jul 2015 18:23:35 -0700
Message-ID: <CAPcyv4hgKmd2V_7FeDLi4cb2EQOPtX4QWhKU1bZBGcKXFFVfDw@mail.gmail.com>
Subject: Re: [PATCH RESEND 0/3] mm, x86: Fix ioremap RAM check interfaces
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, travis@sgi.com, roland@purestorage.com, Luis Rodriguez <mcgrof@suse.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Thu, Jul 16, 2015 at 4:23 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> ioremap() checks if a target range is in RAM and fails the request
> if true.  There are multiple issues in the iormap RAM check interfaces.
>
>  1. region_is_ram() always fails with -1.
>  2. The check calls two functions, region_is_ram() and
>     walk_system_ram_range(), which are redundant as both walk the
>     same iomem_resource table.
>  3. walk_system_ram_range() requires RAM ranges be page-aligned in
>     the iomem_resource table to work properly.  This restriction
>     has allowed multiple ioremaps to RAM which are page-unaligned.
>
> This patchset solves issue 1 and 2.  It does not address issue 3,
> but continues to allow the existing ioremaps to work until it is
> addressed.
>
> ---
> resend:
>  - Rebased to 4.2-rc2 (no change needed). Modified change logs.
>
> ---
> Toshi Kani (3):
>   1/3 mm, x86: Fix warning in ioremap RAM check
>   2/3 mm, x86: Remove region_is_ram() call from ioremap
>   3/3 mm: Fix bugs in region_is_ram()
>

For the series...

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

I'm going to base my ioremap + memremap series on top of these fixes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
