Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 307BE8E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 03:23:46 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id h70-v6so1484973ljf.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 00:23:46 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s5-v6sor2646658ljj.0.2018.09.28.00.23.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Sep 2018 00:23:44 -0700 (PDT)
Subject: Re: [PATCH v5 2/4] mm: move is_kernel_rodata() to
 asm-generic/sections.h
References: <20180928071414.30703-1-brgl@bgdev.pl>
 <20180928071414.30703-3-brgl@bgdev.pl>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <c7484684-8f92-8e7a-e4fb-015d50180414@rasmusvillemoes.dk>
Date: Fri, 28 Sep 2018 09:23:39 +0200
MIME-Version: 1.0
In-Reply-To: <20180928071414.30703-3-brgl@bgdev.pl>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <brgl@bgdev.pl>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Jassi Brar <jassisinghbrar@gmail.com>, Thierry Reding <thierry.reding@gmail.com>, Jonathan Hunter <jonathanh@nvidia.com>, Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On 2018-09-28 09:14, Bartosz Golaszewski wrote:
> Export this routine so that we can use it later in devm_kstrdup_const()
> and devm_kfree_const().

s/devm_kfree_const/devm_kfree/.

Apart from that nit, feel free to add my ack to 1,2,3.

Thanks,
Rasmus
