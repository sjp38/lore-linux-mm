Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB9D58E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 07:44:31 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id z72-v6so3633367itc.8
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 04:44:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 17-v6sor6933539itz.91.2018.09.24.04.44.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 04:44:30 -0700 (PDT)
MIME-Version: 1.0
References: <20180924101150.23349-1-brgl@bgdev.pl> <20180924101150.23349-5-brgl@bgdev.pl>
 <20180924112303.GM15943@smile.fi.intel.com>
In-Reply-To: <20180924112303.GM15943@smile.fi.intel.com>
From: Bartosz Golaszewski <brgl@bgdev.pl>
Date: Mon, 24 Sep 2018 13:44:19 +0200
Message-ID: <CAMRc=McegRtV88BfYja5wdKZuNDEMG3dqWjG7xHoyo6EHhyEqg@mail.gmail.com>
Subject: Re: [PATCH v3 4/4] clk: pmc-atom: use devm_kstrdup_const()
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Kees Cook <keescook@chromium.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, linux-clk <linux-clk@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

pon., 24 wrz 2018 o 13:23 Andy Shevchenko
<andriy.shevchenko@linux.intel.com> napisa=C5=82(a):
>
> On Mon, Sep 24, 2018 at 12:11:50PM +0200, Bartosz Golaszewski wrote:
> > Use devm_kstrdup_const() in the pmc-atom driver. This mostly serves as
> > an example of how to use this new routine to shrink driver code.
> >
> > While we're at it: replace a call to kcalloc() with devm_kcalloc().
>
> > @@ -352,8 +344,6 @@ static int plt_clk_probe(struct platform_device *pd=
ev)
> >               goto err_drop_mclk;
> >       }
> >
> > -     plt_clk_free_parent_names_loop(parent_names, data->nparents);
> > -
> >       platform_set_drvdata(pdev, data);
> >       return 0;
>
> I don't think this is a good example.
>
> You changed a behaviour here in the way that you keep all chunks of memor=
y
> (even small enough for pointers) during entire life time of the driver, w=
hich
> pretty likely would be forever till next boot.
>
> In the original case the memory was freed immediately in probe either it =
fails
> or returns with success.
>
> NAK, sorry.
>
>

I see.

I'd like to still merge patches 1-3 and then I'd come up with better
examples for the next release cycle once these are in?

Bart
