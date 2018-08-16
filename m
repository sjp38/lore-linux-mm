Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 62D836B04FC
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 18:54:46 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c22-v6so154015qkb.18
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 15:54:46 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0097.outbound.protection.outlook.com. [104.47.33.97])
        by mx.google.com with ESMTPS id u73-v6si509597qkl.208.2018.08.16.15.54.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Aug 2018 15:54:44 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [RESEND PATCH v10 2/6] mm: page_alloc: remain
 memblock_next_valid_pfn() on arm/arm64
Date: Thu, 16 Aug 2018 22:54:38 +0000
Message-ID: <20180816225437.5zkchip422esdqwh@xakep.localdomain>
References: <1530867675-9018-1-git-send-email-hejianet@gmail.com>
 <1530867675-9018-3-git-send-email-hejianet@gmail.com>
In-Reply-To: <1530867675-9018-3-git-send-email-hejianet@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <46623D63BEBB1E4ABFC291B2624C8EAD@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pasha Tatashin <Pavel.Tatashin@microsoft.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jia He <jia.he@hxt-semitech.com>

On 18-07-06 17:01:11, Jia He wrote:
> From: Jia He <jia.he@hxt-semitech.com>
>=20
> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
> where possible") optimized the loop in memmap_init_zone(). But it causes
> possible panic bug. So Daniel Vacek reverted it later.
>=20
> But as suggested by Daniel Vacek, it is fine to using memblock to skip
> gaps and finding next valid frame with CONFIG_HAVE_ARCH_PFN_VALID.
> Daniel said:
> "On arm and arm64, memblock is used by default. But generic version of
> pfn_valid() is based on mem sections and memblock_next_valid_pfn() does
> not always return the next valid one but skips more resulting in some
> valid frames to be skipped (as if they were invalid). And that's why
> kernel was eventually crashing on some !arm machines."
>=20
> About the performance consideration:
> As said by James in b92df1de5,
> "I have tested this patch on a virtual model of a Samurai CPU
> with a sparse memory map.  The kernel boot time drops from 109 to
> 62 seconds."
>=20
> Thus it would be better if we remain memblock_next_valid_pfn on arm/arm64=
.
>=20
> Suggested-by: Daniel Vacek <neelx@redhat.com>
> Signed-off-by: Jia He <jia.he@hxt-semitech.com>

The version of this patch in linux-next has few fixes, I reviewed that one
looks good to me.

Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>=
