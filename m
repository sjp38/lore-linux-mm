Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 292596B0005
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 14:26:43 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 13-v6so7315674itl.7
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 11:26:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x73-v6sor2780374iod.259.2018.06.28.11.26.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Jun 2018 11:26:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180627181138.14c9b66e13b8778506205f89@linux-foundation.org>
References: <cover.1530018818.git.andreyknvl@google.com> <20180627160800.3dc7f9ee41c0badbf7342520@linux-foundation.org>
 <CAN=P9pivApAo76Kjc0TUDE0kvJn0pET=47xU6e=ioZV2VqO0Rg@mail.gmail.com>
 <CAEZpscCcP6=O_OCqSwW8Y6u9Ee99SzWN+hRcgpP2tK=OEBFnNw@mail.gmail.com> <20180627181138.14c9b66e13b8778506205f89@linux-foundation.org>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 28 Jun 2018 20:26:39 +0200
Message-ID: <CAAeHK+wg35W6D3Cat7w8kqV+9fB6dKmnCUuUrZP_tz5=vKk+0Q@mail.gmail.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address sanitizer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vishwath Mohan <vishwath@google.com>, Kostya Serebryany <kcc@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Evgenii Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>

On Thu, Jun 28, 2018 at 3:11 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 27 Jun 2018 17:59:00 -0700 Vishwath Mohan <vishwath@google.com> wrote:
>> Yeah, I can confirm that it's an issue. Like Kostya mentioned, I don't have
>> data on-hand, but anecdotally both ASAN and KASAN have proven problematic
>> to enable for environments that don't tolerate the increased memory
>> pressure well. This includes,
>> (a) Low-memory form factors - Wear, TV, Things, lower-tier phones like Go
>> (c) Connected components like Pixel's visual core
>> <https://www.blog.google/products/pixel/pixel-visual-core-image-processing-and-machine-learning-pixel-2/>
>>
>>
>> These are both places I'd love to have a low(er) memory footprint option at
>> my disposal.
>
> Thanks.
>
> It really is important that such information be captured in the
> changelogs.  In as much detail as can be mustered.

I'll add it to the changelog in v5. Thanks!
