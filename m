Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0EAD86B0007
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 13:49:00 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f17-v6so9810584plr.1
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 10:49:00 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e3-v6si1899355pga.369.2018.10.12.10.48.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 10:48:58 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Stephen Boyd <sboyd@kernel.org>
In-Reply-To: <CAMRc=McmvkWEKV71pX9_PbNaYYf2VpovO2JrUQckWJ_0taqCZw@mail.gmail.com>
References: <20180828093332.20674-1-brgl@bgdev.pl>
 <CAMRc=McmvkWEKV71pX9_PbNaYYf2VpovO2JrUQckWJ_0taqCZw@mail.gmail.com>
Message-ID: <153936653758.5275.9529030954345523691@swboyd.mtv.corp.google.com>
Subject: Re: [PATCH v2 0/4] devres: provide and use devm_kstrdup_const()
Date: Fri, 12 Oct 2018 10:48:57 -0700
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <brgl@bgdev.pl>
Cc: linux-clk <linux-clk@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Arend van Spriel <aspriel@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Bjorn Andersson <bjorn.andersson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Joe Perches <joe@perches.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Michael Turquette <mturquette@baylibre.com>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Robin Murphy <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>, Ulf Hansson <ulf.hansson@linaro.org>, Vivek Gautam <vivek.gautam@codeaurora.org>

Quoting Bartosz Golaszewski (2018-09-20 05:59:54)
> 2018-08-28 11:33 GMT+02:00 Bartosz Golaszewski <brgl@bgdev.pl>:
> > This series implements devm_kstrdup_const() together with some
> > prerequisite changes and uses it in pmc-atom driver.
> >
> > v1 -> v2:
> > - fixed the changelog in the patch implementing devm_kstrdup_const()
> > - fixed the kernel doc
> > - moved is_kernel_rodata() to asm-generic/sections.h
> > - fixed constness
> >
> > Bartosz Golaszewski (4):
> >   devres: constify p in devm_kfree()
> >   mm: move is_kernel_rodata() to asm-generic/sections.h
> >   devres: provide devm_kstrdup_const()
> >   clk: pmc-atom: use devm_kstrdup_const()
> >
> >  drivers/base/devres.c          | 43 ++++++++++++++++++++++++++++++++--
> >  drivers/clk/x86/clk-pmc-atom.c | 19 ++++-----------
> >  include/asm-generic/sections.h | 14 +++++++++++
> >  include/linux/device.h         |  5 +++-
> >  mm/util.c                      |  7 ------
> >  5 files changed, 63 insertions(+), 25 deletions(-)
> >
> > --
> > 2.18.0
> >
> =

> If there are no objections - can this be picked up for 4.20?
> =


There are so many people on To: line who do you want to pick this up?
Maybe you can send a pull request to Greg directly.
