Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id C2C846B027B
	for <linux-mm@kvack.org>; Fri,  4 May 2018 14:33:57 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id v10-v6so14260205oth.16
        for <linux-mm@kvack.org>; Fri, 04 May 2018 11:33:57 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y5-v6sor7043824oig.19.2018.05.04.11.33.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 May 2018 11:33:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <23b14717-0f4a-10f2-5118-7cb8445fbdab@oracle.com>
References: <1523431317-30612-1-git-send-email-hejianet@gmail.com>
 <05b0fcf2-7670-101e-d4ab-1f656ff6b02f@gmail.com> <CACjP9X8bHmrxmd7ZPcfQq6Eq0Mzwmt0saOR3Ph53gp2n-dcKBQ@mail.gmail.com>
 <23b14717-0f4a-10f2-5118-7cb8445fbdab@oracle.com>
From: Daniel Vacek <neelx@redhat.com>
Date: Fri, 4 May 2018 20:33:56 +0200
Message-ID: <CACjP9X950MTY9qZ7OkzEaph3U1BL8Vo9sT4jBZ8HTuhHez9JAw@mail.gmail.com>
Subject: Re: [PATCH v8 0/6] optimize memblock_next_valid_pfn and
 early_pfn_valid on arm and arm64
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Jia He <hejianet@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, open list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, May 4, 2018 at 6:53 PM, Pavel Tatashin
<pasha.tatashin@oracle.com> wrote:
>> I'm wondering, ain't simple enabling of config
>> DEFERRED_STRUCT_PAGE_INIT provide even better speed-up? If that is the
>> case then it seems like this series is not needed at all, right?
>> I am not sure why is this config optional. It looks like it could be
>> enabled by default or even unconditionally considering that with
>> commit c9e97a1997fb ("mm: initialize pages on demand during boot") the
>> deferred code is statically disabled after all the pages are
>> initialized.
>
> Hi Daniel,
>
> Currently, deferred struct pages are initialized in parallel only on NUMA=
 machines. I would like to make a change to use all the available CPUs even=
 on a single socket systems, but that is not there yet. So, I believe Jia's=
 performance improvements are still relevant.

Ahaa, I thought it also works on UP or single node systems. I didn't
study the code closely. Sorry about the noise. And thank you, Pavel.
You're right.

--nX

> Thank you,
> Pavel
