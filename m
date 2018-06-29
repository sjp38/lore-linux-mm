Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 157E36B000A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 09:43:46 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id f8-v6so8885933qtb.23
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 06:43:46 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id e186-v6si3446555qkd.80.2018.06.29.06.43.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 06:43:44 -0700 (PDT)
Date: Fri, 29 Jun 2018 16:42:57 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address
 sanitizer
Message-ID: <20180629134257.ci5ninozkh2ni6wd@mwanda>
References: <cover.1530018818.git.andreyknvl@google.com>
 <20180628105057.GA26019@e103592.cambridge.arm.com>
 <CAAeHK+w0T43+h3xqU4a-qutxd-qiEhsvk0eaZpmAn-T0hpaLZQ@mail.gmail.com>
 <20180629110419.GC26019@e103592.cambridge.arm.com>
 <20180629112613.7i4xesjyxolc63gu@ltop.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180629112613.7i4xesjyxolc63gu@ltop.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Cc: Dave Martin <Dave.Martin@arm.com>, Andrey Konovalov <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-doc@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Paul Lawrence <paullawrence@google.com>, Linux Memory Management List <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Christoph Lameter <cl@linux.com>, Ingo Molnar <mingo@kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-sparse@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Evgeniy Stepanov <eugenis@google.com>, Arnd Bergmann <arnd@arndb.de>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nick Desaulniers <ndesaulniers@google.com>, LKML <linux-kernel@vger.kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, smatch@vger.kernel.org

On Fri, Jun 29, 2018 at 01:26:14PM +0200, Luc Van Oostenryck wrote:
> On Fri, Jun 29, 2018 at 12:04:22PM +0100, Dave Martin wrote:
> > 
> > Can sparse be hacked to identify pointer subtractions where the pointers
> > are cannot be statically proved to point into the same allocation?
> 
> sparse only see the (deatils of) the function it analyses and all
> visible declarations, nothing more.
> 
> It would be more a job for smatch which do global analysis.
> But to identify such subtractions yu must already have a (good)
> pointer alias analysis which I don't think smatch do (but I can
> be wrong, Dan & smatch's ml added in CC).

That would be hard to manage.  Maybe in a year from now...

Pointer math errors tend to get caught pretty quick because they're on
the success path so I don't imagine there are huge numbers of bugs.

regards,
dan carpenter
