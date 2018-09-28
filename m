Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 891E48E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 03:28:43 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id s204-v6so1343882vke.23
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 00:28:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e18-v6sor2419947vkd.8.2018.09.28.00.28.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Sep 2018 00:28:42 -0700 (PDT)
MIME-Version: 1.0
References: <20180928071414.30703-1-brgl@bgdev.pl> <20180928071414.30703-2-brgl@bgdev.pl>
In-Reply-To: <20180928071414.30703-2-brgl@bgdev.pl>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 28 Sep 2018 09:28:29 +0200
Message-ID: <CAMuHMdW7wAhQJ6tgB58sENrSV_GmxLZQvASg8B8UxP9UH7NmpA@mail.gmail.com>
Subject: Re: [PATCH v5 1/4] devres: constify p in devm_kfree()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <brgl@bgdev.pl>
Cc: Greg KH <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Jassi Brar <jassisinghbrar@gmail.com>, Thierry Reding <thierry.reding@gmail.com>, Jon Hunter <jonathanh@nvidia.com>, Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-tegra@vger.kernel.org, Linux-Arch <linux-arch@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Fri, Sep 28, 2018 at 9:14 AM Bartosz Golaszewski <brgl@bgdev.pl> wrote:
> Make devm_kfree() signature uniform with that of kfree(). To avoid
> compiler warnings: cast p to (void *) when calling devres_destroy().

Hmm, devres_destroy(), devres_remove(), and find_dr() really should
take const void pointers.  But that requires changing dr_match_t, and
fixing up all users...

> Signed-off-by: Bartosz Golaszewski <brgl@bgdev.pl>
> Reviewed-by: Bjorn Andersson <bjorn.andersson@linaro.org>

Reviewed-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
