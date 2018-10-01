Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 798196B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 12:14:26 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id p8-v6so17026978pfn.23
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 09:14:26 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id z12-v6si8513289pgv.387.2018.10.01.09.14.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 09:14:25 -0700 (PDT)
Date: Mon, 1 Oct 2018 19:09:01 +0300
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH v6 0/4] devres: provide and use devm_kstrdup_const()
Message-ID: <20181001160901.GY15943@smile.fi.intel.com>
References: <20180930202615.12951-1-brgl@bgdev.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180930202615.12951-1-brgl@bgdev.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <brgl@bgdev.pl>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Jassi Brar <jassisinghbrar@gmail.com>, Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Sun, Sep 30, 2018 at 10:26:11PM +0200, Bartosz Golaszewski wrote:
> This series implements devm_kstrdup_const() together with some
> prerequisite changes and uses it in tegra-hsp driver.

Thanks!
For the first three,
Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

> 
> v1 -> v2:
> - fixed the changelog in the patch implementing devm_kstrdup_const()
> - fixed the kernel doc
> - moved is_kernel_rodata() to asm-generic/sections.h
> - fixed constness
> 
> v2 -> v3:
> - rebased on top of 4.19-rc5 as there were some conflicts in the
>   pmc-atom driver
> - collected Reviewed-by tags
> 
> v3 -> v4:
> - Andy NAK'ed patch 4/4 so I added a different example
> - collected more tags
> 
> v4 -> v5:
> - instead of providing devm_kfree_const(), make devm_kfree() check if
>   given pointer is not in .rodata and act accordingly
> 
> v5 -> v6:
> - fixed the commit message in patch 2/4 (s/devm_kfree_const/devm_kfree/)
> - collected even more tags
> 
> Bartosz Golaszewski (4):
>   devres: constify p in devm_kfree()
>   mm: move is_kernel_rodata() to asm-generic/sections.h
>   devres: provide devm_kstrdup_const()
>   mailbox: tegra-hsp: use devm_kstrdup_const()
> 
>  drivers/base/devres.c          | 36 +++++++++++++++++++++++++++--
>  drivers/mailbox/tegra-hsp.c    | 41 ++++++++--------------------------
>  include/asm-generic/sections.h | 14 ++++++++++++
>  include/linux/device.h         |  4 +++-
>  mm/util.c                      |  7 ------
>  5 files changed, 60 insertions(+), 42 deletions(-)
> 
> -- 
> 2.18.0
> 

-- 
With Best Regards,
Andy Shevchenko
