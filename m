Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D72E56B0007
	for <linux-mm@kvack.org>; Sun, 25 Mar 2018 19:58:52 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m188so10641687qkd.15
        for <linux-mm@kvack.org>; Sun, 25 Mar 2018 16:58:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u7sor63064qkb.22.2018.03.25.16.58.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Mar 2018 16:58:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180318125342.4278-1-liuwenliang@huawei.com>
References: <20180318125342.4278-1-liuwenliang@huawei.com>
From: Joel Stanley <joel@jms.id.au>
Date: Mon, 26 Mar 2018 10:28:30 +1030
Message-ID: <CACPK8XemuC+uACYp=tP1gJ8=9k-S69saebOLmq8nrZtqPxWRjw@mail.gmail.com>
Subject: Re: [PATCH v2 0/7] KASan for arm
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Abbott Liu <liuwenliang@huawei.com>
Cc: Russell King <linux@armlinux.org.uk>, aryabinin@virtuozzo.com, Marc Zyngier <marc.zyngier@arm.com>, kstewart@linuxfoundation.org, Greg KH <gregkh@linuxfoundation.org>, Florian Fainelli <f.fainelli@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Afzal Mohammed <afzal.mohd.ma@gmail.com>, alexander.levin@verizon.com, glider@google.com, dvyukov@google.com, Christoffer Dall <christoffer.dall@linaro.org>, linux@rasmusvillemoes.dk, mawilcox@microsoft.com, Philippe Ombredanne <pombredanne@nexb.com>, ard.biesheuvel@linaro.org, vladimir.murzin@arm.com, nicolas.pitre@linaro.org, Thomas Gleixner <tglx@linutronix.de>, thgarnie@google.com, dhowells@redhat.com, Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, "Jon Medhurst (Tixy)" <tixy@linaro.org>, Mark Rutland <mark.rutland@arm.com>, james.morse@arm.com, zhichao.huang@linaro.org, jinb.park7@gmail.com, labbott@redhat.com, philip@cog.systems, grygorii.strashko@linaro.org, catalin.marinas@arm.com, opendmb@gmail.com, kirill.shutemov@linux.intel.com, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, linux-mm@kvack.org

On 18 March 2018 at 23:23, Abbott Liu <liuwenliang@huawei.com> wrote:

>    These patches add arch specific code for kernel address sanitizer
> (see Documentation/kasan.txt).

Thanks for implementing this. I gave the series a spin on an ASPEED
ast2500 (ARMv5) system with aspeed_g5_defconfig.

It found a bug in the NCSI code (https://github.com/openbmc/linux/issues/146).

Tested-by: Joel Stanley <joel@jms.id.au>

Cheers,

Joel
