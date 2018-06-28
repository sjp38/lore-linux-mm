Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7296C6B0005
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 15:40:44 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a20-v6so1854345pfi.1
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 12:40:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y192-v6si5697221pgd.656.2018.06.28.12.40.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 12:40:42 -0700 (PDT)
Date: Thu, 28 Jun 2018 12:40:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address
 sanitizer
Message-Id: <20180628124039.8a42ab5e2994fb2876ff4f75@linux-foundation.org>
In-Reply-To: <CAAeHK+xz552VNpZxgWwU-hbTqF5_F6YVDw3fSv=4OT8mNrqPzg@mail.gmail.com>
References: <cover.1530018818.git.andreyknvl@google.com>
	<20180627160800.3dc7f9ee41c0badbf7342520@linux-foundation.org>
	<CAAeHK+xz552VNpZxgWwU-hbTqF5_F6YVDw3fSv=4OT8mNrqPzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>

On Thu, 28 Jun 2018 20:29:07 +0200 Andrey Konovalov <andreyknvl@google.com> wrote:

> >> Slab memory usage after boot [2]:
> >> * ~40 kb for clean kernel
> >> * ~105 kb + 1/8th shadow ~= 118 kb for KASAN
> >> * ~47 kb + 1/16th shadow ~= 50 kb for KHWASAN
> >>
> >> Network performance [3]:
> >> * 8.33 Gbits/sec for clean kernel
> >> * 3.17 Gbits/sec for KASAN
> >> * 2.85 Gbits/sec for KHWASAN
> >>
> >> Note, that KHWASAN (compared to KASAN) doesn't require quarantine.
> >>
> >> [1] Time before the ext4 driver is initialized.
> >> [2] Measured as `cat /proc/meminfo | grep Slab`.
> >> [3] Measured as `iperf -s & iperf -c 127.0.0.1 -t 30`.
> >
> > The above doesn't actually demonstrate the whole point of the
> > patchset: to reduce KASAN's very high memory consumption?
> 
> You mean that memory usage numbers collected after boot don't give a
> representative picture of actual memory consumption on real workloads?
> 
> What kind of memory consumption testing would you like to see?

Well, 100kb or so is a teeny amount on virtually any machine.  I'm
assuming the savings are (much) more significant once the machine gets
loaded up and doing work?
