Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DB53C6B0007
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 07:26:18 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l23-v6so2899684edr.1
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 04:26:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d1-v6sor3702087edp.7.2018.06.29.04.26.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Jun 2018 04:26:17 -0700 (PDT)
Date: Fri, 29 Jun 2018 13:26:14 +0200
From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address
 sanitizer
Message-ID: <20180629112613.7i4xesjyxolc63gu@ltop.local>
References: <cover.1530018818.git.andreyknvl@google.com>
 <20180628105057.GA26019@e103592.cambridge.arm.com>
 <CAAeHK+w0T43+h3xqU4a-qutxd-qiEhsvk0eaZpmAn-T0hpaLZQ@mail.gmail.com>
 <20180629110419.GC26019@e103592.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180629110419.GC26019@e103592.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Martin <Dave.Martin@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-doc@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Paul Lawrence <paullawrence@google.com>, Linux Memory Management List <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Christoph Lameter <cl@linux.com>, Ingo Molnar <mingo@kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-sparse@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Evgeniy Stepanov <eugenis@google.com>, Arnd Bergmann <arnd@arndb.de>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nick Desaulniers <ndesaulniers@google.com>, LKML <linux-kernel@vger.kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, smatch@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>

On Fri, Jun 29, 2018 at 12:04:22PM +0100, Dave Martin wrote:
> 
> Can sparse be hacked to identify pointer subtractions where the pointers
> are cannot be statically proved to point into the same allocation?

sparse only see the (deatils of) the function it analyses and all
visible declarations, nothing more.

It would be more a job for smatch which do global analysis.
But to identify such subtractions yu must already have a (good)
pointer alias analysis which I don't think smatch do (but I can
be wrong, Dan & smatch's ml added in CC).

-- Luc Van Oostenryck
