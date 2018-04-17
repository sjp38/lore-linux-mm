Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id D50C56B0008
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:27:39 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e22-v6so12180685ita.0
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 05:27:39 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d132sor1915985iof.234.2018.04.17.05.27.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Apr 2018 05:27:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <c95bd92f-bef4-378a-55ed-04439c784e43@virtuozzo.com>
References: <4ad725cc903f8534f8c8a60f0daade5e3d674f8d.1523554166.git.andreyknvl@google.com>
 <b849e2ff-3693-9546-5850-1ddcea23ee29@virtuozzo.com> <CAAeHK+y18zU_PAS5KB82PNqtvGNex+S0Jk3bWaE19=YjThaNow@mail.gmail.com>
 <c95bd92f-bef4-378a-55ed-04439c784e43@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 17 Apr 2018 14:27:37 +0200
Message-ID: <CAAeHK+xSsnPwBC__K+LODAYSwtPkBYReA0yOV=K=We1exzamCg@mail.gmail.com>
Subject: Re: [PATCH] kasan: add no_sanitize attribute for clang builds
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, David Woodhouse <dwmw@amazon.co.uk>, Will Deacon <will.deacon@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paul Lawrence <paullawrence@google.com>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, Kostya Serebryany <kcc@google.com>

On Fri, Apr 13, 2018 at 9:16 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> However, "#ifdef CONFIG_KASAN" seems to be redundant, I'd rather remove it.

Done, sent v2.

Thanks!
