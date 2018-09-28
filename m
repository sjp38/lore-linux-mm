Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 150218E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 03:30:58 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id o62-v6so1406308vko.1
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 00:30:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a11-v6sor3162297uao.10.2018.09.28.00.30.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Sep 2018 00:30:57 -0700 (PDT)
MIME-Version: 1.0
References: <20180928071414.30703-1-brgl@bgdev.pl> <20180928071414.30703-4-brgl@bgdev.pl>
In-Reply-To: <20180928071414.30703-4-brgl@bgdev.pl>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 28 Sep 2018 09:30:45 +0200
Message-ID: <CAMuHMdVF9zD+KZ8E1-BCrn4W2QngABHqnCajOhk3Y=xpq4R=Cg@mail.gmail.com>
Subject: Re: [PATCH v5 3/4] devres: provide devm_kstrdup_const()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <brgl@bgdev.pl>
Cc: Greg KH <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Jassi Brar <jassisinghbrar@gmail.com>, Thierry Reding <thierry.reding@gmail.com>, Jon Hunter <jonathanh@nvidia.com>, Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-tegra@vger.kernel.org, Linux-Arch <linux-arch@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Fri, Sep 28, 2018 at 9:14 AM Bartosz Golaszewski <brgl@bgdev.pl> wrote:
> Provide a resource managed version of kstrdup_const(). This variant
> internally calls devm_kstrdup() on pointers that are outside of
> .rodata section and returns the string as is otherwise.
>
> Make devm_kfree() check if the passed pointer doesn't point to .rodata
> and if so - don't actually destroy the resource.
>
> Signed-off-by: Bartosz Golaszewski <brgl@bgdev.pl>
> Reviewed-by: Bjorn Andersson <bjorn.andersson@linaro.org>
> Acked-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Reviewed-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
