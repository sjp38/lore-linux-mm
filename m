Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id D8F9A8E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 08:59:56 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id w132-v6so12433146ita.6
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 05:59:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l14-v6sor962362iti.85.2018.09.20.05.59.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Sep 2018 05:59:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180828093332.20674-1-brgl@bgdev.pl>
References: <20180828093332.20674-1-brgl@bgdev.pl>
From: Bartosz Golaszewski <brgl@bgdev.pl>
Date: Thu, 20 Sep 2018 14:59:54 +0200
Message-ID: <CAMRc=McmvkWEKV71pX9_PbNaYYf2VpovO2JrUQckWJ_0taqCZw@mail.gmail.com>
Subject: Re: [PATCH v2 0/4] devres: provide and use devm_kstrdup_const()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Kees Cook <keescook@chromium.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>
Cc: linux-clk <linux-clk@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Bartosz Golaszewski <brgl@bgdev.pl>

2018-08-28 11:33 GMT+02:00 Bartosz Golaszewski <brgl@bgdev.pl>:
> This series implements devm_kstrdup_const() together with some
> prerequisite changes and uses it in pmc-atom driver.
>
> v1 -> v2:
> - fixed the changelog in the patch implementing devm_kstrdup_const()
> - fixed the kernel doc
> - moved is_kernel_rodata() to asm-generic/sections.h
> - fixed constness
>
> Bartosz Golaszewski (4):
>   devres: constify p in devm_kfree()
>   mm: move is_kernel_rodata() to asm-generic/sections.h
>   devres: provide devm_kstrdup_const()
>   clk: pmc-atom: use devm_kstrdup_const()
>
>  drivers/base/devres.c          | 43 ++++++++++++++++++++++++++++++++--
>  drivers/clk/x86/clk-pmc-atom.c | 19 ++++-----------
>  include/asm-generic/sections.h | 14 +++++++++++
>  include/linux/device.h         |  5 +++-
>  mm/util.c                      |  7 ------
>  5 files changed, 63 insertions(+), 25 deletions(-)
>
> --
> 2.18.0
>

If there are no objections - can this be picked up for 4.20?

Thanks,
Bartosz
