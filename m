Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 164CC6B0007
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 14:29:10 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id x13-v6so4902526iog.16
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 11:29:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b195-v6sor2949234itc.138.2018.06.28.11.29.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Jun 2018 11:29:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180627160800.3dc7f9ee41c0badbf7342520@linux-foundation.org>
References: <cover.1530018818.git.andreyknvl@google.com> <20180627160800.3dc7f9ee41c0badbf7342520@linux-foundation.org>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 28 Jun 2018 20:29:07 +0200
Message-ID: <CAAeHK+xz552VNpZxgWwU-hbTqF5_F6YVDw3fSv=4OT8mNrqPzg@mail.gmail.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address sanitizer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>

On Thu, Jun 28, 2018 at 1:08 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 26 Jun 2018 15:15:10 +0200 Andrey Konovalov <andreyknvl@google.com> wrote:
>> ====== Benchmarks
>>
>> The following numbers were collected on Odroid C2 board. Both KASAN and
>> KHWASAN were used in inline instrumentation mode.
>>
>> Boot time [1]:
>> * ~1.7 sec for clean kernel
>> * ~5.0 sec for KASAN
>> * ~5.0 sec for KHWASAN
>>
>> Slab memory usage after boot [2]:
>> * ~40 kb for clean kernel
>> * ~105 kb + 1/8th shadow ~= 118 kb for KASAN
>> * ~47 kb + 1/16th shadow ~= 50 kb for KHWASAN
>>
>> Network performance [3]:
>> * 8.33 Gbits/sec for clean kernel
>> * 3.17 Gbits/sec for KASAN
>> * 2.85 Gbits/sec for KHWASAN
>>
>> Note, that KHWASAN (compared to KASAN) doesn't require quarantine.
>>
>> [1] Time before the ext4 driver is initialized.
>> [2] Measured as `cat /proc/meminfo | grep Slab`.
>> [3] Measured as `iperf -s & iperf -c 127.0.0.1 -t 30`.
>
> The above doesn't actually demonstrate the whole point of the
> patchset: to reduce KASAN's very high memory consumption?

You mean that memory usage numbers collected after boot don't give a
representative picture of actual memory consumption on real workloads?

What kind of memory consumption testing would you like to see?
