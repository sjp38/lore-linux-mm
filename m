Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 407BD8E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 08:12:07 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d40-v6so9897192pla.14
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 05:12:07 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k198-v6si5196964pga.12.2018.09.24.05.12.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 05:12:06 -0700 (PDT)
Date: Mon, 24 Sep 2018 15:11:38 +0300
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH v3 4/4] clk: pmc-atom: use devm_kstrdup_const()
Message-ID: <20180924121138.GN15943@smile.fi.intel.com>
References: <20180924101150.23349-1-brgl@bgdev.pl>
 <20180924101150.23349-5-brgl@bgdev.pl>
 <20180924112303.GM15943@smile.fi.intel.com>
 <CAMRc=McegRtV88BfYja5wdKZuNDEMG3dqWjG7xHoyo6EHhyEqg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAMRc=McegRtV88BfYja5wdKZuNDEMG3dqWjG7xHoyo6EHhyEqg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <brgl@bgdev.pl>
Cc: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Kees Cook <keescook@chromium.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, linux-clk <linux-clk@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Sep 24, 2018 at 01:44:19PM +0200, Bartosz Golaszewski wrote:
> pon., 24 wrz 2018 o 13:23 Andy Shevchenko
> <andriy.shevchenko@linux.intel.com> napisaA?(a):
> >
> > On Mon, Sep 24, 2018 at 12:11:50PM +0200, Bartosz Golaszewski wrote:
> > > Use devm_kstrdup_const() in the pmc-atom driver. This mostly serves as
> > > an example of how to use this new routine to shrink driver code.
> > >
> > > While we're at it: replace a call to kcalloc() with devm_kcalloc().
> >
> > > @@ -352,8 +344,6 @@ static int plt_clk_probe(struct platform_device *pdev)
> > >               goto err_drop_mclk;
> > >       }
> > >
> > > -     plt_clk_free_parent_names_loop(parent_names, data->nparents);
> > > -
> > >       platform_set_drvdata(pdev, data);
> > >       return 0;
> >
> > I don't think this is a good example.
> >
> > You changed a behaviour here in the way that you keep all chunks of memory
> > (even small enough for pointers) during entire life time of the driver, which
> > pretty likely would be forever till next boot.
> >
> > In the original case the memory was freed immediately in probe either it fails
> > or returns with success.
> >
> > NAK, sorry.
> >
> >
> 
> I see.
> 
> I'd like to still merge patches 1-3 and then I'd come up with better
> examples for the next release cycle once these are in?

I'm fine with first three, though I can't come up with better example for you
now. My previous comment solely to clk-pmc-atom code.

-- 
With Best Regards,
Andy Shevchenko
