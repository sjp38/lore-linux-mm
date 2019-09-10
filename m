Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8180CC49ED9
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 05:43:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 362F921479
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 05:43:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 362F921479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8EFF6B0003; Tue, 10 Sep 2019 01:43:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3ECE6B0006; Tue, 10 Sep 2019 01:43:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2DB76B0007; Tue, 10 Sep 2019 01:43:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0111.hostedemail.com [216.40.44.111])
	by kanga.kvack.org (Postfix) with ESMTP id 93A196B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 01:43:13 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 2EB7D181AC9BF
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:43:13 +0000 (UTC)
X-FDA: 75917917866.22.bells76_1be962bd95d3d
X-HE-Tag: bells76_1be962bd95d3d
X-Filterd-Recvd-Size: 14426
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:43:11 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A514B28;
	Mon,  9 Sep 2019 22:43:10 -0700 (PDT)
Received: from [10.162.40.137] (p8cg001049571a15.blr.arm.com [10.162.40.137])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 53DA43F67D;
	Mon,  9 Sep 2019 22:45:25 -0700 (PDT)
Subject: Re: [PATCH 1/1] mm/pgtable/debug: Add test validating architecture
 page table helpers
To: Christophe Leroy <christophe.leroy@c-s.fr>,
 "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org,
 linux-sh@vger.kernel.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>,
 Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
 Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>,
 sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
 linux-s390@vger.kernel.org, x86@kernel.org,
 Russell King - ARM Linux <linux@armlinux.org.uk>,
 Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>,
 Jason Gunthorpe <jgg@ziepe.ca>, Vlastimil Babka <vbabka@suse.cz>,
 linux-snps-arc@lists.infradead.org, Kees Cook <keescook@chromium.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Mark Brown <broonie@kernel.org>, Dan Williams <dan.j.williams@intel.com>,
 Gerald Schaefer <gerald.schaefer@de.ibm.com>,
 linux-arm-kernel@lists.infradead.org,
 Sri Krishna chowdary <schowdary@nvidia.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org,
 Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org,
 Peter Zijlstra <peterz@infradead.org>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>, Paul Burton <paul.burton@mips.com>,
 Vineet Gupta <vgupta@synopsys.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org,
 "David S. Miller" <davem@davemloft.net>
References: <1567497706-8649-1-git-send-email-anshuman.khandual@arm.com>
 <1567497706-8649-2-git-send-email-anshuman.khandual@arm.com>
 <20190904221618.1b624a98@thinkpad>
 <20e3044d-2af5-b27b-7653-cec53bdec941@arm.com>
 <20190905190629.523bdb87@thinkpad>
 <3c609e33-afbb-ffaf-481a-6d225a06d1d0@arm.com>
 <20190906210346.5ecbff01@thinkpad>
 <3d5de35f-8192-1c75-50a9-03e66e3b8e5c@arm.com>
 <20190909151344.ghfypjbgxyosjdk3@box>
 <5883d41a-8299-1584-aa3d-fac89b3d9b5b@arm.com>
 <94029d96-47c4-3020-57a8-4e03de1b4fc8@c-s.fr>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <b0e2c87c-1130-4219-246b-e050a9da2a39@arm.com>
Date: Tue, 10 Sep 2019 11:13:07 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <94029d96-47c4-3020-57a8-4e03de1b4fc8@c-s.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 09/10/2019 10:15 AM, Christophe Leroy wrote:
>=20
>=20
> On 09/10/2019 03:56 AM, Anshuman Khandual wrote:
>>
>>
>> On 09/09/2019 08:43 PM, Kirill A. Shutemov wrote:
>>> On Mon, Sep 09, 2019 at 11:56:50AM +0530, Anshuman Khandual wrote:
>>>>
>>>>
>>>> On 09/07/2019 12:33 AM, Gerald Schaefer wrote:
>>>>> On Fri, 6 Sep 2019 11:58:59 +0530
>>>>> Anshuman Khandual <anshuman.khandual@arm.com> wrote:
>>>>>
>>>>>> On 09/05/2019 10:36 PM, Gerald Schaefer wrote:
>>>>>>> On Thu, 5 Sep 2019 14:48:14 +0530
>>>>>>> Anshuman Khandual <anshuman.khandual@arm.com> wrote:
>>>>>>> =C2=A0=C2=A0
>>>>>>>>> [...]
>>>>>>>>>> +
>>>>>>>>>> +#if !defined(__PAGETABLE_PMD_FOLDED) && !defined(__ARCH_HAS_4=
LEVEL_HACK)
>>>>>>>>>> +static void pud_clear_tests(pud_t *pudp)
>>>>>>>>>> +{
>>>>>>>>>> +=C2=A0=C2=A0=C2=A0 memset(pudp, RANDOM_NZVALUE, sizeof(pud_t)=
);
>>>>>>>>>> +=C2=A0=C2=A0=C2=A0 pud_clear(pudp);
>>>>>>>>>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pud_none(READ_ONCE(*pudp)));
>>>>>>>>>> +}
>>>>>>>>>
>>>>>>>>> For pgd/p4d/pud_clear(), we only clear if the page table level =
is present
>>>>>>>>> and not folded. The memset() here overwrites the table type bit=
s, so
>>>>>>>>> pud_clear() will not clear anything on s390 and the pud_none() =
check will
>>>>>>>>> fail.
>>>>>>>>> Would it be possible to OR a (larger) random value into the tab=
le, so that
>>>>>>>>> the lower 12 bits would be preserved?
>>>>>>>>
>>>>>>>> So the suggestion is instead of doing memset() on entry with RAN=
DOM_NZVALUE,
>>>>>>>> it should OR a large random value preserving lower 12 bits. Hmm,=
 this should
>>>>>>>> still do the trick for other platforms, they just need non zero =
value. So on
>>>>>>>> s390, the lower 12 bits on the page table entry already has vali=
d value while
>>>>>>>> entering this function which would make sure that pud_clear() re=
ally does
>>>>>>>> clear the entry ?
>>>>>>>
>>>>>>> Yes, in theory the table entry on s390 would have the type set in=
 the last
>>>>>>> 4 bits, so preserving those would be enough. If it does not confl=
ict with
>>>>>>> others, I would still suggest preserving all 12 bits since those =
would contain
>>>>>>> arch-specific flags in general, just to be sure. For s390, the pt=
e/pmd tests
>>>>>>> would also work with the memset, but for consistency I think the =
same logic
>>>>>>> should be used in all pxd_clear_tests.
>>>>>>
>>>>>> Makes sense but..
>>>>>>
>>>>>> There is a small challenge with this. Modifying individual bits on=
 a given
>>>>>> page table entry from generic code like this test case is bit tric=
ky. That
>>>>>> is because there are not enough helpers to create entries with an =
absolute
>>>>>> value. This would have been easier if all the platforms provided f=
unctions
>>>>>> like __pxx() which is not the case now. Otherwise something like t=
his should
>>>>>> have worked.
>>>>>>
>>>>>>
>>>>>> pud_t pud =3D READ_ONCE(*pudp);
>>>>>> pud =3D __pud(pud_val(pud) | RANDOM_VALUE (keeping lower 12 bits 0=
))
>>>>>> WRITE_ONCE(*pudp, pud);
>>>>>>
>>>>>> But __pud() will fail to build in many platforms.
>>>>>
>>>>> Hmm, I simply used this on my system to make pud_clear_tests() work=
, not
>>>>> sure if it works on all archs:
>>>>>
>>>>> pud_val(*pudp) |=3D RANDOM_NZVALUE;
>>>>
>>>> Which compiles on arm64 but then fails on x86 because of the way pmd=
_val()
>>>> has been defined there.
>>>
>>> Use instead
>>>
>>> =C2=A0=C2=A0=C2=A0=C2=A0*pudp =3D __pud(pud_val(*pudp) | RANDOM_NZVAL=
UE);
>>
>> Agreed.
>>
>> As I had mentioned before this would have been really the cleanest app=
roach.
>>
>>>
>>> It *should* be more portable.
>>
>> Not really, because not all the platforms have __pxx() definitions rig=
ht now.
>> Going with these will clearly cause build failures on affected platfor=
ms. Lets
>> examine __pud() for instance. It is defined only on these platforms.
>>
>> arch/arm64/include/asm/pgtable-types.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 #define __pud(x) ((pud_t) { (x) } )
>> arch/mips/include/asm/pgtable-64.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 #define __pud(x) ((pud_t) { (x) })
>> arch/powerpc/include/asm/pgtable-be-types.h:=C2=A0=C2=A0=C2=A0 #define=
 __pud(x) ((pud_t) { cpu_to_be64(x) })
>> arch/powerpc/include/asm/pgtable-types.h:=C2=A0=C2=A0=C2=A0 #define __=
pud(x) ((pud_t) { (x) })
>> arch/s390/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 #define __pud(x) ((pud_t) { (x) } )
>> arch/sparc/include/asm/page_64.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 #define __pud(x) ((pud_t) { (x) } )
>> arch/sparc/include/asm/page_64.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 #define __pud(x) (x)
>> arch/x86/include/asm/pgtable.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 #define __pud(x) native_make_pud(x)
>=20
> You missed:
> arch/x86/include/asm/paravirt.h:static inline pud_t __pud(pudval_t val)
> include/asm-generic/pgtable-nop4d-hack.h:#define __pud(x) =C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ((p=
ud_t) { __pgd(x) })
> include/asm-generic/pgtable-nopud.h:#define __pud(x) =C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 ((pud_t) { __p4d(x) })
>=20
>>
>> Similarly for __pmd()
>>
>> arch/alpha/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 #define __pmd(x)=C2=A0 ((pmd_t) { (x) } )
>> arch/arm/include/asm/page-nommu.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 #define __pmd(x)=C2=A0 (x)
>> arch/arm/include/asm/pgtable-2level-types.h:=C2=A0=C2=A0=C2=A0 #define=
 __pmd(x)=C2=A0 ((pmd_t) { (x) } )
>> arch/arm/include/asm/pgtable-2level-types.h:=C2=A0=C2=A0=C2=A0 #define=
 __pmd(x)=C2=A0 (x)
>> arch/arm/include/asm/pgtable-3level-types.h:=C2=A0=C2=A0=C2=A0 #define=
 __pmd(x)=C2=A0 ((pmd_t) { (x) } )
>> arch/arm/include/asm/pgtable-3level-types.h:=C2=A0=C2=A0=C2=A0 #define=
 __pmd(x)=C2=A0 (x)
>> arch/arm64/include/asm/pgtable-types.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 #define __pmd(x)=C2=A0 ((pmd_t) { (x) } )
>> arch/m68k/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 #define __pmd(x)=C2=A0 ((pmd_t) { { (x) }, })
>> arch/mips/include/asm/pgtable-64.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 #define __pmd(x)=C2=A0 ((pmd_t) { (x) } )
>> arch/nds32/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 #define __pmd(x)=C2=A0 (x)
>> arch/parisc/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 #define __pmd(x)=C2=A0 ((pmd_t) { (x) } )
>> arch/parisc/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 #define __pmd(x)=C2=A0 (x)
>> arch/powerpc/include/asm/pgtable-be-types.h:=C2=A0=C2=A0=C2=A0 #define=
 __pmd(x)=C2=A0 ((pmd_t) { cpu_to_be64(x) })
>> arch/powerpc/include/asm/pgtable-types.h:=C2=A0=C2=A0=C2=A0 #define __=
pmd(x)=C2=A0 ((pmd_t) { (x) })
>> arch/riscv/include/asm/pgtable-64.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 #define __pmd(x)=C2=A0 ((pmd_t) { (x) })
>> arch/s390/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 #define __pmd(x)=C2=A0 ((pmd_t) { (x) } )
>> arch/sh/include/asm/pgtable-3level.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 #define __pmd(x)=C2=A0 ((pmd_t) { (x) } )
>> arch/sparc/include/asm/page_32.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 #define __pmd(x)=C2=A0 ((pmd_t) { { (x) }, })
>> arch/sparc/include/asm/page_32.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 #define __pmd(x)=C2=A0 ((pmd_t) { { (x) }, })
>> arch/sparc/include/asm/page_64.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 #define __pmd(x)=C2=A0 ((pmd_t) { (x) } )
>> arch/sparc/include/asm/page_64.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 #define __pmd(x)=C2=A0 (x)
>> arch/um/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 #define __pmd(x)=C2=A0 ((pmd_t) { (x) } )
>> arch/um/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 #define __pmd(x)=C2=A0 ((pmd_t) { (x) } )
>> arch/x86/include/asm/pgtable.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 #define __pmd(x)=C2=A0 native_make_pmd(x)
>=20
> You missed:
> arch/x86/include/asm/paravirt.h:static inline pmd_t __pmd(pmdval_t val)
> include/asm-generic/page.h:#define __pmd(x)=C2=A0=C2=A0=C2=A0=C2=A0 ((p=
md_t) { (x) } )
> include/asm-generic/pgtable-nopmd.h:#define __pmd(x) =C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 ((pmd_t) { __pud(x) } )
>=20
>=20
>>
>> Similarly for __pgd()
>>
>> arch/alpha/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) } )
>> arch/alpha/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 #define __pgd(x)=C2=A0 (x)
>> arch/arc/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) })
>> arch/arc/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 #define __pgd(x)=C2=A0 (x)
>> arch/arm/include/asm/pgtable-3level-types.h:=C2=A0=C2=A0=C2=A0 #define=
 __pgd(x)=C2=A0 ((pgd_t) { (x) } )
>> arch/arm/include/asm/pgtable-3level-types.h:=C2=A0=C2=A0=C2=A0 #define=
 __pgd(x)=C2=A0 (x)
>> arch/arm64/include/asm/pgtable-types.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) } )
>> arch/csky/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) })
>> arch/hexagon/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) })
>> arch/m68k/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) } )
>> arch/mips/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) } )
>> arch/nds32/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 #define __pgd(x)=C2=A0 (x)
>> arch/nios2/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) })
>> arch/openrisc/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) })
>> arch/parisc/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) } )
>> arch/parisc/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 #define __pgd(x)=C2=A0 (x)
>> arch/powerpc/include/asm/pgtable-be-types.h:=C2=A0=C2=A0=C2=A0 #define=
 __pgd(x)=C2=A0 ((pgd_t) { cpu_to_be64(x) })
>> arch/powerpc/include/asm/pgtable-types.h:=C2=A0=C2=A0=C2=A0 #define __=
pgd(x)=C2=A0 ((pgd_t) { (x) })
>> arch/riscv/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) })
>> arch/s390/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) } )
>> arch/sh/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) } )
>> arch/sparc/include/asm/page_32.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) } )
>> arch/sparc/include/asm/page_32.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 #define __pgd(x)=C2=A0 (x)
>> arch/sparc/include/asm/page_64.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) } )
>> arch/sparc/include/asm/page_64.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 #define __pgd(x)=C2=A0 (x)
>> arch/um/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) } )
>> arch/unicore32/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) })
>> arch/unicore32/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 #define __pgd(x)=C2=A0 (x)
>> arch/x86/include/asm/pgtable.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 #define __pgd(x)=C2=A0 native_make_pgd(x)
>> arch/xtensa/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 #define __pgd(x)=C2=A0 ((pgd_t) { (x) } )
>=20
> You missed:
> arch/x86/include/asm/paravirt.h:static inline pgd_t __pgd(pgdval_t val)
> include/asm-generic/page.h:#define __pgd(x)=C2=A0=C2=A0=C2=A0=C2=A0 ((p=
gd_t) { (x) } )
>=20
>=20
>>
>> Similarly for __p4d()
>>
>> arch/s390/include/asm/page.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 #define __p4d(x)=C2=A0 ((p4d_t) { (x) } )
>> arch/x86/include/asm/pgtable.h:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 #define __p4d(x)=C2=A0 native_make_p4d(x)
>=20
> You missed:
> arch/x86/include/asm/paravirt.h:static inline p4d_t __p4d(p4dval_t val)
> include/asm-generic/5level-fixup.h:#define __p4d(x) __pgd(x)
> include/asm-generic/pgtable-nop4d.h:#define __p4d(x) =C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 ((p4d_t) { __pgd(x) })
>=20
>=20
>>
>> The search pattern here has been "#define __pxx(". Unless I am missing=
 something,
>> I dont see how we can use these without risking build failures.
>>
>=20
> I guess you missed that arches not defining them fall back on the defin=
itions in include/asm-generic

You are right. I was confused whether these generic definitions were real=
ly
applicable for all those platforms as fallback (with so many page table
level folding combinations available) when they dont define. Sure will ta=
ke
this approach and try to build them on multiple platforms.

