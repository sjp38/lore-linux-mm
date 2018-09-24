Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id C57E38E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 07:20:52 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id a3-v6so38359511iod.23
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 04:20:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 17-v6sor6907894itz.91.2018.09.24.04.20.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 04:20:51 -0700 (PDT)
MIME-Version: 1.0
References: <20180924101150.23349-1-brgl@bgdev.pl> <20180924111601.GL15943@smile.fi.intel.com>
In-Reply-To: <20180924111601.GL15943@smile.fi.intel.com>
From: Bartosz Golaszewski <brgl@bgdev.pl>
Date: Mon, 24 Sep 2018 13:20:40 +0200
Message-ID: <CAMRc=MdKAoWscwJR4=3DLMGA-DTHU1wJg0SSSgo=7KbgPa_9DA@mail.gmail.com>
Subject: Re: [PATCH v3 0/4] devres: provide and use devm_kstrdup_const()
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Kees Cook <keescook@chromium.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, linux-clk <linux-clk@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

pon., 24 wrz 2018 o 13:16 Andy Shevchenko
<andriy.shevchenko@linux.intel.com> napisa=C5=82(a):
>
> On Mon, Sep 24, 2018 at 12:11:46PM +0200, Bartosz Golaszewski wrote:
> > This series implements devm_kstrdup_const() together with some
> > prerequisite changes and uses it in pmc-atom driver.
> >
>
> Through which tree you are assuming this would be directed?
>

I think that patches 1-3 would be best picked up by Andrew Morton.
Patch 4 looks like it should go through the clock tree unless Stephen
is fine with Acking it and it going through the mm tree together with
others.

Bart

> > v1 -> v2:
> > - fixed the changelog in the patch implementing devm_kstrdup_const()
> > - fixed the kernel doc
> > - moved is_kernel_rodata() to asm-generic/sections.h
> > - fixed constness
> >
> > v2 -> v3:
> > - rebased on top of 4.19-rc5 as there were some conflicts in the
> >   pmc-atom driver
> > - collected Reviewed-by tags
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
>
> --
> With Best Regards,
> Andy Shevchenko
>
>
