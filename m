Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D68EC4CEC5
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 15:36:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C19D720578
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 15:36:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="vXjHrIsD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C19D720578
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 425506B0005; Thu, 12 Sep 2019 11:36:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D66D6B0006; Thu, 12 Sep 2019 11:36:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29E5D6B0007; Thu, 12 Sep 2019 11:36:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0191.hostedemail.com [216.40.44.191])
	by kanga.kvack.org (Postfix) with ESMTP id F0EB06B0005
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 11:36:29 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 9221955FB7
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 15:36:29 +0000 (UTC)
X-FDA: 75926670498.25.bean38_55ade557ed355
X-HE-Tag: bean38_55ade557ed355
X-Filterd-Recvd-Size: 26301
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 15:36:28 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 46TjY55kR1zB09Zp;
	Thu, 12 Sep 2019 17:36:25 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=vXjHrIsD; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id DwyHfJ_-hmk0; Thu, 12 Sep 2019 17:36:25 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 46TjY54MYgzB09ZC;
	Thu, 12 Sep 2019 17:36:25 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1568302585; bh=IhIV2LM0kJGGv/F34RdYML5IiQ3nwig+HBKPEh4K5vw=;
	h=Subject:From:To:Cc:References:Date:In-Reply-To:From;
	b=vXjHrIsDpNVTmPIV+FqFTM1WOKwePeTDgnCH7EOvfA3I9YCObdf/G7pwoOKTK0TOf
	 acGFsLp+5pfGsxUu4d+5NxmkiphS/982bTUxvlc0xdlN3kmadTDcMIZfwEX6wJ4VmX
	 yzksD6pyopcgU+LT4RasTCt4C9sSQU6knXxj1T+o=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 2E1CA8B945;
	Thu, 12 Sep 2019 17:36:27 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id NEjtA1ocC_FG; Thu, 12 Sep 2019 17:36:27 +0200 (CEST)
Received: from [192.168.4.90] (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 0B0BC8B933;
	Thu, 12 Sep 2019 17:36:25 +0200 (CEST)
Subject: Re: [PATCH V2 2/2] mm/pgtable/debug: Add test validating architecture
 page table helpers
From: Christophe Leroy <christophe.leroy@c-s.fr>
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org,
 linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
 James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>,
 Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
 Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org,
 Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org,
 Jason Gunthorpe <jgg@ziepe.ca>, x86@kernel.org,
 Russell King - ARM Linux <linux@armlinux.org.uk>,
 Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Gerald Schaefer <gerald.schaefer@de.ibm.com>,
 linux-snps-arc@lists.infradead.org, Kees Cook <keescook@chromium.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov"
 <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>,
 Vlastimil Babka <vbabka@suse.cz>, linux-arm-kernel@lists.infradead.org,
 Sri Krishna chowdary <schowdary@nvidia.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org,
 Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org,
 Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Vineet Gupta <vgupta@synopsys.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org,
 "David S. Miller" <davem@davemloft.net>
References: <1568268173-31302-1-git-send-email-anshuman.khandual@arm.com>
 <1568268173-31302-3-git-send-email-anshuman.khandual@arm.com>
 <4cf31ca9-39e4-87e4-7eef-a6f3f0ea7576@c-s.fr>
Message-ID: <31aa6043-3b11-a936-bf35-6ed84bff9304@c-s.fr>
Date: Thu, 12 Sep 2019 17:36:24 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.9.0
MIME-Version: 1.0
In-Reply-To: <4cf31ca9-39e4-87e4-7eef-a6f3f0ea7576@c-s.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 12/09/2019 =C3=A0 17:00, Christophe Leroy a =C3=A9crit=C2=A0:
>=20
>=20
> On 09/12/2019 06:02 AM, Anshuman Khandual wrote:
>> This adds a test module which will validate architecture page table=20
>> helpers
>> and accessors regarding compliance with generic MM semantics=20
>> expectations.
>> This will help various architectures in validating changes to the=20
>> existing
>> page table helpers or addition of new ones.
>>
>> Test page table and memory pages creating it's entries at various=20
>> level are
>> all allocated from system memory with required alignments. If memory=20
>> pages
>> with required size and alignment could not be allocated, then all=20
>> depending
>> individual tests are skipped.
>=20
> Build failure on powerpc book3s/32. This is because asm/highmem.h is=20
> missing. It can't be included from asm/book3s/32/pgtable.h because it=20
> creates circular dependency. So it has to be included from=20
> mm/arch_pgtable_test.c

In fact it is <linux/highmem.h> that needs to be added, adding=20
<asm/highmem.h> directly provokes build failure at link time.

Christophe

>=20
>=20
>=20
>  =C2=A0 CC=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 mm/arch_pgtable_test.o
> In file included from ./arch/powerpc/include/asm/book3s/pgtable.h:8:0,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 from ./arch/powerpc/include/asm/pgtable.h:18,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 from ./include/linux/mm.h:99,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 from ./arch/powerpc/include/asm/io.h:29,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 from ./include/linux/io.h:13,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 from ./include/linux/irq.h:20,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 from ./arch/powerpc/include/asm/hardirq.h:6,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 from ./include/linux/hardirq.h:9,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 from ./include/linux/interrupt.h:11,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 from ./include/linux/kernel_stat.h:9,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 from ./include/linux/cgroup.h:26,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 from ./include/linux/hugetlb.h:9,
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 from mm/arch_pgtable_test.c:14:
> mm/arch_pgtable_test.c: In function 'arch_pgtable_tests_init':
> ./arch/powerpc/include/asm/book3s/32/pgtable.h:365:13: error: implicit=20
> declaration of function 'kmap_atomic'=20
> [-Werror=3Dimplicit-function-declaration]
>  =C2=A0 ((pte_t *)(kmap_atomic(pmd_page(*(dir))) + \
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 ^
> ./include/linux/mm.h:2008:31: note: in expansion of macro 'pte_offset_m=
ap'
>  =C2=A0 (pte_alloc(mm, pmd) ? NULL : pte_offset_map(pmd, address))
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^
> mm/arch_pgtable_test.c:377:9: note: in expansion of macro 'pte_alloc_ma=
p'
>  =C2=A0 ptep =3D pte_alloc_map(mm, pmdp, vaddr);
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ^
> cc1: some warnings being treated as errors
> make[2]: *** [mm/arch_pgtable_test.o] Error 1
>=20
>=20
> Christophe
>=20
>=20
>>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
>> Cc: Jason Gunthorpe <jgg@ziepe.ca>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Cc: Peter Zijlstra <peterz@infradead.org>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Mark Rutland <mark.rutland@arm.com>
>> Cc: Mark Brown <broonie@kernel.org>
>> Cc: Steven Price <Steven.Price@arm.com>
>> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
>> Cc: Kees Cook <keescook@chromium.org>
>> Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Sri Krishna chowdary <schowdary@nvidia.com>
>> Cc: Dave Hansen <dave.hansen@intel.com>
>> Cc: Russell King - ARM Linux <linux@armlinux.org.uk>
>> Cc: Michael Ellerman <mpe@ellerman.id.au>
>> Cc: Paul Mackerras <paulus@samba.org>
>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: Vineet Gupta <vgupta@synopsys.com>
>> Cc: James Hogan <jhogan@kernel.org>
>> Cc: Paul Burton <paul.burton@mips.com>
>> Cc: Ralf Baechle <ralf@linux-mips.org>
>> Cc: Kirill A. Shutemov <kirill@shutemov.name>
>> Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
>> Cc: Christophe Leroy <christophe.leroy@c-s.fr>
>> Cc: linux-snps-arc@lists.infradead.org
>> Cc: linux-mips@vger.kernel.org
>> Cc: linux-arm-kernel@lists.infradead.org
>> Cc: linux-ia64@vger.kernel.org
>> Cc: linuxppc-dev@lists.ozlabs.org
>> Cc: linux-s390@vger.kernel.org
>> Cc: linux-sh@vger.kernel.org
>> Cc: sparclinux@vger.kernel.org
>> Cc: x86@kernel.org
>> Cc: linux-kernel@vger.kernel.org
>>
>> Suggested-by: Catalin Marinas <catalin.marinas@arm.com>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>> =C2=A0 arch/x86/include/asm/pgtable_64_types.h |=C2=A0=C2=A0 2 +
>> =C2=A0 mm/Kconfig.debug=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 |=C2=A0 14 +
>> =C2=A0 mm/Makefile=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0=C2=A0 1 +
>> =C2=A0 mm/arch_pgtable_test.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 429 ++++++=
++++++++++++++++++
>> =C2=A0 4 files changed, 446 insertions(+)
>> =C2=A0 create mode 100644 mm/arch_pgtable_test.c
>>
>> diff --git a/arch/x86/include/asm/pgtable_64_types.h=20
>> b/arch/x86/include/asm/pgtable_64_types.h
>> index 52e5f5f2240d..b882792a3999 100644
>> --- a/arch/x86/include/asm/pgtable_64_types.h
>> +++ b/arch/x86/include/asm/pgtable_64_types.h
>> @@ -40,6 +40,8 @@ static inline bool pgtable_l5_enabled(void)
>> =C2=A0 #define pgtable_l5_enabled() 0
>> =C2=A0 #endif /* CONFIG_X86_5LEVEL */
>> +#define mm_p4d_folded(mm) (!pgtable_l5_enabled())
>> +
>> =C2=A0 extern unsigned int pgdir_shift;
>> =C2=A0 extern unsigned int ptrs_per_p4d;
>> diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
>> index 327b3ebf23bf..ce9c397f7b07 100644
>> --- a/mm/Kconfig.debug
>> +++ b/mm/Kconfig.debug
>> @@ -117,3 +117,17 @@ config DEBUG_RODATA_TEST
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 depends on STRICT_KERNEL_RWX
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ---help---
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 This option enables a testc=
ase for the setting rodata read-only.
>> +
>> +config DEBUG_ARCH_PGTABLE_TEST
>> +=C2=A0=C2=A0=C2=A0 bool "Test arch page table helpers for semantics c=
ompliance"
>> +=C2=A0=C2=A0=C2=A0 depends on MMU
>> +=C2=A0=C2=A0=C2=A0 depends on DEBUG_KERNEL
>> +=C2=A0=C2=A0=C2=A0 help
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 This options provides a kernel module =
which can be used to test
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 architecture page table helper functio=
ns on various platform in
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 verifying if they comply with expected=
 generic MM semantics. This
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 will help architectures code in making=
 sure that any changes or
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 new additions of these helpers will st=
ill conform to generic MM
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 expected semantics.
>> +
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 If unsure, say N.
>> diff --git a/mm/Makefile b/mm/Makefile
>> index d996846697ef..bb572c5aa8c5 100644
>> --- a/mm/Makefile
>> +++ b/mm/Makefile
>> @@ -86,6 +86,7 @@ obj-$(CONFIG_HWPOISON_INJECT) +=3D hwpoison-inject.o
>> =C2=A0 obj-$(CONFIG_DEBUG_KMEMLEAK) +=3D kmemleak.o
>> =C2=A0 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) +=3D kmemleak-test.o
>> =C2=A0 obj-$(CONFIG_DEBUG_RODATA_TEST) +=3D rodata_test.o
>> +obj-$(CONFIG_DEBUG_ARCH_PGTABLE_TEST) +=3D arch_pgtable_test.o
>> =C2=A0 obj-$(CONFIG_PAGE_OWNER) +=3D page_owner.o
>> =C2=A0 obj-$(CONFIG_CLEANCACHE) +=3D cleancache.o
>> =C2=A0 obj-$(CONFIG_MEMORY_ISOLATION) +=3D page_isolation.o
>> diff --git a/mm/arch_pgtable_test.c b/mm/arch_pgtable_test.c
>> new file mode 100644
>> index 000000000000..8b4a92756ad8
>> --- /dev/null
>> +++ b/mm/arch_pgtable_test.c
>> @@ -0,0 +1,429 @@
>> +// SPDX-License-Identifier: GPL-2.0-only
>> +/*
>> + * This kernel module validates architecture page table helpers &
>> + * accessors and helps in verifying their continued compliance with
>> + * generic MM semantics.
>> + *
>> + * Copyright (C) 2019 ARM Ltd.
>> + *
>> + * Author: Anshuman Khandual <anshuman.khandual@arm.com>
>> + */
>> +#define pr_fmt(fmt) "arch_pgtable_test: %s " fmt, __func__
>> +
>> +#include <linux/gfp.h>
>> +#include <linux/hugetlb.h>
>> +#include <linux/kernel.h>
>> +#include <linux/mm.h>
>> +#include <linux/mman.h>
>> +#include <linux/mm_types.h>
>> +#include <linux/module.h>
>> +#include <linux/pfn_t.h>
>> +#include <linux/printk.h>
>> +#include <linux/random.h>
>> +#include <linux/spinlock.h>
>> +#include <linux/swap.h>
>> +#include <linux/swapops.h>
>> +#include <linux/sched/mm.h>
>> +#include <asm/pgalloc.h>
>> +#include <asm/pgtable.h>
>> +
>> +/*
>> + * Basic operations
>> + *
>> + * mkold(entry)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 =3D An old and not a young entry
>> + * mkyoung(entry)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =3D A you=
ng and not an old entry
>> + * mkdirty(entry)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =3D A dir=
ty and not a clean entry
>> + * mkclean(entry)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =3D A cle=
an and not a dirty entry
>> + * mkwrite(entry)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =3D A wri=
te and not a write protected entry
>> + * wrprotect(entry)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =3D A w=
rite protected and not a write entry
>> + * pxx_bad(entry)=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =3D A map=
ped and non-table entry
>> + * pxx_same(entry1, entry2)=C2=A0=C2=A0=C2=A0 =3D Both entries hold t=
he exact same value
>> + */
>> +#define VMFLAGS=C2=A0=C2=A0=C2=A0 (VM_READ|VM_WRITE|VM_EXEC)
>> +
>> +/*
>> + * On s390 platform, the lower 12 bits are used to identify given=20
>> page table
>> + * entry type and for other arch specific requirements. But these=20
>> bits might
>> + * affect the ability to clear entries with pxx_clear(). So while=20
>> loading up
>> + * the entries skip all lower 12 bits in order to accommodate s390=20
>> platform.
>> + * It does not have affect any other platform.
>> + */
>> +#define RANDOM_ORVALUE=C2=A0=C2=A0=C2=A0 (0xfffffffffffff000UL)
>> +#define RANDOM_NZVALUE=C2=A0=C2=A0=C2=A0 (0xff)
>> +
>> +static bool pud_aligned;
>> +static bool pmd_aligned;
>> +
>> +static void pte_basic_tests(struct page *page, pgprot_t prot)
>> +{
>> +=C2=A0=C2=A0=C2=A0 pte_t pte =3D mk_pte(page, prot);
>> +
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pte_same(pte, pte));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pte_young(pte_mkyoung(pte)));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pte_dirty(pte_mkdirty(pte)));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pte_write(pte_mkwrite(pte)));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(pte_young(pte_mkold(pte)));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(pte_dirty(pte_mkclean(pte)));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(pte_write(pte_wrprotect(pte)));
>> +}
>> +
>> +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE
>> +static void pmd_basic_tests(struct page *page, pgprot_t prot)
>> +{
>> +=C2=A0=C2=A0=C2=A0 pmd_t pmd;
>> +
>> +=C2=A0=C2=A0=C2=A0 /*
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * Memory block here must be PMD_SIZE aligned=
. Abort this
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * test in case we could not allocate such a =
memory block.
>> +=C2=A0=C2=A0=C2=A0=C2=A0 */
>> +=C2=A0=C2=A0=C2=A0 if (!pmd_aligned) {
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pr_warn("Could not proceed=
 with PMD tests\n");
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return;
>> +=C2=A0=C2=A0=C2=A0 }
>> +
>> +=C2=A0=C2=A0=C2=A0 pmd =3D mk_pmd(page, prot);
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pmd_same(pmd, pmd));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pmd_young(pmd_mkyoung(pmd)));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pmd_dirty(pmd_mkdirty(pmd)));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pmd_write(pmd_mkwrite(pmd)));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(pmd_young(pmd_mkold(pmd)));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(pmd_dirty(pmd_mkclean(pmd)));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(pmd_write(pmd_wrprotect(pmd)));
>> +=C2=A0=C2=A0=C2=A0 /*
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * A huge page does not point to next level p=
age table
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * entry. Hence this must qualify as pmd_bad(=
).
>> +=C2=A0=C2=A0=C2=A0=C2=A0 */
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pmd_bad(pmd_mkhuge(pmd)));
>> +}
>> +#else
>> +static void pmd_basic_tests(struct page *page, pgprot_t prot) { }
>> +#endif
>> +
>> +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
>> +static void pud_basic_tests(struct page *page, pgprot_t prot)
>> +{
>> +=C2=A0=C2=A0=C2=A0 pud_t pud;
>> +
>> +=C2=A0=C2=A0=C2=A0 /*
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * Memory block here must be PUD_SIZE aligned=
. Abort this
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * test in case we could not allocate such a =
memory block.
>> +=C2=A0=C2=A0=C2=A0=C2=A0 */
>> +=C2=A0=C2=A0=C2=A0 if (!pud_aligned) {
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pr_warn("Could not proceed=
 with PUD tests\n");
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return;
>> +=C2=A0=C2=A0=C2=A0 }
>> +
>> +=C2=A0=C2=A0=C2=A0 pud =3D pfn_pud(page_to_pfn(page), prot);
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pud_same(pud, pud));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pud_young(pud_mkyoung(pud)));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pud_write(pud_mkwrite(pud)));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(pud_write(pud_wrprotect(pud)));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(pud_young(pud_mkold(pud)));
>> +
>> +#if !defined(__PAGETABLE_PMD_FOLDED) && !defined(__ARCH_HAS_4LEVEL_HA=
CK)
>> +=C2=A0=C2=A0=C2=A0 /*
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * A huge page does not point to next level p=
age table
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * entry. Hence this must qualify as pud_bad(=
).
>> +=C2=A0=C2=A0=C2=A0=C2=A0 */
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pud_bad(pud_mkhuge(pud)));
>> +#endif
>> +}
>> +#else
>> +static void pud_basic_tests(struct page *page, pgprot_t prot) { }
>> +#endif
>> +
>> +static void p4d_basic_tests(struct page *page, pgprot_t prot)
>> +{
>> +=C2=A0=C2=A0=C2=A0 p4d_t p4d;
>> +
>> +=C2=A0=C2=A0=C2=A0 memset(&p4d, RANDOM_NZVALUE, sizeof(p4d_t));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!p4d_same(p4d, p4d));
>> +}
>> +
>> +static void pgd_basic_tests(struct page *page, pgprot_t prot)
>> +{
>> +=C2=A0=C2=A0=C2=A0 pgd_t pgd;
>> +
>> +=C2=A0=C2=A0=C2=A0 memset(&pgd, RANDOM_NZVALUE, sizeof(pgd_t));
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pgd_same(pgd, pgd));
>> +}
>> +
>> +#if !defined(__PAGETABLE_PMD_FOLDED) && !defined(__ARCH_HAS_4LEVEL_HA=
CK)
>> +static void pud_clear_tests(pud_t *pudp)
>> +{
>> +=C2=A0=C2=A0=C2=A0 pud_t pud =3D READ_ONCE(*pudp);
>> +
>> +=C2=A0=C2=A0=C2=A0 pud =3D __pud(pud_val(pud) | RANDOM_ORVALUE);
>> +=C2=A0=C2=A0=C2=A0 WRITE_ONCE(*pudp, pud);
>> +=C2=A0=C2=A0=C2=A0 pud_clear(pudp);
>> +=C2=A0=C2=A0=C2=A0 pud =3D READ_ONCE(*pudp);
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pud_none(pud));
>> +}
>> +
>> +static void pud_populate_tests(struct mm_struct *mm, pud_t *pudp,=20
>> pmd_t *pmdp)
>> +{
>> +=C2=A0=C2=A0=C2=A0 pud_t pud;
>> +
>> +=C2=A0=C2=A0=C2=A0 /*
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * This entry points to next level page table=
 page.
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * Hence this must not qualify as pud_bad().
>> +=C2=A0=C2=A0=C2=A0=C2=A0 */
>> +=C2=A0=C2=A0=C2=A0 pmd_clear(pmdp);
>> +=C2=A0=C2=A0=C2=A0 pud_clear(pudp);
>> +=C2=A0=C2=A0=C2=A0 pud_populate(mm, pudp, pmdp);
>> +=C2=A0=C2=A0=C2=A0 pud =3D READ_ONCE(*pudp);
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(pud_bad(pud));
>> +}
>> +#else
>> +static void pud_clear_tests(pud_t *pudp) { }
>> +static void pud_populate_tests(struct mm_struct *mm, pud_t *pudp,=20
>> pmd_t *pmdp)
>> +{
>> +}
>> +#endif
>> +
>> +#if !defined(__PAGETABLE_PUD_FOLDED) && !defined(__ARCH_HAS_5LEVEL_HA=
CK)
>> +static void p4d_clear_tests(p4d_t *p4dp)
>> +{
>> +=C2=A0=C2=A0=C2=A0 p4d_t p4d =3D READ_ONCE(*p4dp);
>> +
>> +=C2=A0=C2=A0=C2=A0 p4d =3D __p4d(p4d_val(p4d) | RANDOM_ORVALUE);
>> +=C2=A0=C2=A0=C2=A0 WRITE_ONCE(*p4dp, p4d);
>> +=C2=A0=C2=A0=C2=A0 p4d_clear(p4dp);
>> +=C2=A0=C2=A0=C2=A0 p4d =3D READ_ONCE(*p4dp);
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!p4d_none(p4d));
>> +}
>> +
>> +static void p4d_populate_tests(struct mm_struct *mm, p4d_t *p4dp,=20
>> pud_t *pudp)
>> +{
>> +=C2=A0=C2=A0=C2=A0 p4d_t p4d;
>> +
>> +=C2=A0=C2=A0=C2=A0 /*
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * This entry points to next level page table=
 page.
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * Hence this must not qualify as p4d_bad().
>> +=C2=A0=C2=A0=C2=A0=C2=A0 */
>> +=C2=A0=C2=A0=C2=A0 pud_clear(pudp);
>> +=C2=A0=C2=A0=C2=A0 p4d_clear(p4dp);
>> +=C2=A0=C2=A0=C2=A0 p4d_populate(mm, p4dp, pudp);
>> +=C2=A0=C2=A0=C2=A0 p4d =3D READ_ONCE(*p4dp);
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(p4d_bad(p4d));
>> +}
>> +#else
>> +static void p4d_clear_tests(p4d_t *p4dp) { }
>> +static void p4d_populate_tests(struct mm_struct *mm, p4d_t *p4dp,=20
>> pud_t *pudp)
>> +{
>> +}
>> +#endif
>> +
>> +#ifndef __ARCH_HAS_5LEVEL_HACK
>> +static void pgd_clear_tests(struct mm_struct *mm, pgd_t *pgdp)
>> +{
>> +=C2=A0=C2=A0=C2=A0 pgd_t pgd =3D READ_ONCE(*pgdp);
>> +
>> +=C2=A0=C2=A0=C2=A0 if (mm_p4d_folded(mm))
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return;
>> +
>> +=C2=A0=C2=A0=C2=A0 pgd =3D __pgd(pgd_val(pgd) | RANDOM_ORVALUE);
>> +=C2=A0=C2=A0=C2=A0 WRITE_ONCE(*pgdp, pgd);
>> +=C2=A0=C2=A0=C2=A0 pgd_clear(pgdp);
>> +=C2=A0=C2=A0=C2=A0 pgd =3D READ_ONCE(*pgdp);
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pgd_none(pgd));
>> +}
>> +
>> +static void pgd_populate_tests(struct mm_struct *mm, pgd_t *pgdp,=20
>> p4d_t *p4dp)
>> +{
>> +=C2=A0=C2=A0=C2=A0 pgd_t pgd;
>> +
>> +=C2=A0=C2=A0=C2=A0 if (mm_p4d_folded(mm))
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return;
>> +
>> +=C2=A0=C2=A0=C2=A0 /*
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * This entry points to next level page table=
 page.
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * Hence this must not qualify as pgd_bad().
>> +=C2=A0=C2=A0=C2=A0=C2=A0 */
>> +=C2=A0=C2=A0=C2=A0 p4d_clear(p4dp);
>> +=C2=A0=C2=A0=C2=A0 pgd_clear(pgdp);
>> +=C2=A0=C2=A0=C2=A0 pgd_populate(mm, pgdp, p4dp);
>> +=C2=A0=C2=A0=C2=A0 pgd =3D READ_ONCE(*pgdp);
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(pgd_bad(pgd));
>> +}
>> +#else
>> +static void pgd_clear_tests(struct mm_struct *mm, pgd_t *pgdp) { }
>> +static void pgd_populate_tests(struct mm_struct *mm, pgd_t *pgdp,=20
>> p4d_t *p4dp)
>> +{
>> +}
>> +#endif
>> +
>> +static void pte_clear_tests(struct mm_struct *mm, pte_t *ptep)
>> +{
>> +=C2=A0=C2=A0=C2=A0 pte_t pte =3D READ_ONCE(*ptep);
>> +
>> +=C2=A0=C2=A0=C2=A0 pte =3D __pte(pte_val(pte) | RANDOM_ORVALUE);
>> +=C2=A0=C2=A0=C2=A0 WRITE_ONCE(*ptep, pte);
>> +=C2=A0=C2=A0=C2=A0 pte_clear(mm, 0, ptep);
>> +=C2=A0=C2=A0=C2=A0 pte =3D READ_ONCE(*ptep);
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pte_none(pte));
>> +}
>> +
>> +static void pmd_clear_tests(pmd_t *pmdp)
>> +{
>> +=C2=A0=C2=A0=C2=A0 pmd_t pmd =3D READ_ONCE(*pmdp);
>> +
>> +=C2=A0=C2=A0=C2=A0 pmd =3D __pmd(pmd_val(pmd) | RANDOM_ORVALUE);
>> +=C2=A0=C2=A0=C2=A0 WRITE_ONCE(*pmdp, pmd);
>> +=C2=A0=C2=A0=C2=A0 pmd_clear(pmdp);
>> +=C2=A0=C2=A0=C2=A0 pmd =3D READ_ONCE(*pmdp);
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(!pmd_none(pmd));
>> +}
>> +
>> +static void pmd_populate_tests(struct mm_struct *mm, pmd_t *pmdp,
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pgtable_t pgtable)
>> +{
>> +=C2=A0=C2=A0=C2=A0 pmd_t pmd;
>> +
>> +=C2=A0=C2=A0=C2=A0 /*
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * This entry points to next level page table=
 page.
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * Hence this must not qualify as pmd_bad().
>> +=C2=A0=C2=A0=C2=A0=C2=A0 */
>> +=C2=A0=C2=A0=C2=A0 pmd_clear(pmdp);
>> +=C2=A0=C2=A0=C2=A0 pmd_populate(mm, pmdp, pgtable);
>> +=C2=A0=C2=A0=C2=A0 pmd =3D READ_ONCE(*pmdp);
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(pmd_bad(pmd));
>> +}
>> +
>> +static struct page *alloc_mapped_page(void)
>> +{
>> +=C2=A0=C2=A0=C2=A0 struct page *page;
>> +=C2=A0=C2=A0=C2=A0 gfp_t gfp_mask =3D GFP_KERNEL | __GFP_ZERO;
>> +
>> +=C2=A0=C2=A0=C2=A0 page =3D alloc_gigantic_page_order(get_order(PUD_S=
IZE), gfp_mask,
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 first_memory_node, &node_states[N_MEMORY]);
>> +=C2=A0=C2=A0=C2=A0 if (page) {
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pud_aligned =3D true;
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pmd_aligned =3D true;
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return page;
>> +=C2=A0=C2=A0=C2=A0 }
>> +
>> +=C2=A0=C2=A0=C2=A0 page =3D alloc_pages(gfp_mask, get_order(PMD_SIZE)=
);
>> +=C2=A0=C2=A0=C2=A0 if (page) {
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pmd_aligned =3D true;
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return page;
>> +=C2=A0=C2=A0=C2=A0 }
>> +=C2=A0=C2=A0=C2=A0 return alloc_page(gfp_mask);
>> +}
>> +
>> +static void free_mapped_page(struct page *page)
>> +{
>> +=C2=A0=C2=A0=C2=A0 if (pud_aligned) {
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 unsigned long pfn =3D page=
_to_pfn(page);
>> +
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 free_contig_range(pfn, 1UL=
L << get_order(PUD_SIZE));
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return;
>> +=C2=A0=C2=A0=C2=A0 }
>> +
>> +=C2=A0=C2=A0=C2=A0 if (pmd_aligned) {
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 int order =3D get_order(PM=
D_SIZE);
>> +
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 free_pages((unsigned long)=
page_address(page), order);
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return;
>> +=C2=A0=C2=A0=C2=A0 }
>> +=C2=A0=C2=A0=C2=A0 free_page((unsigned long)page_address(page));
>> +}
>> +
>> +static unsigned long get_random_vaddr(void)
>> +{
>> +=C2=A0=C2=A0=C2=A0 unsigned long random_vaddr, random_pages, total_us=
er_pages;
>> +
>> +=C2=A0=C2=A0=C2=A0 total_user_pages =3D (TASK_SIZE - FIRST_USER_ADDRE=
SS) / PAGE_SIZE;
>> +
>> +=C2=A0=C2=A0=C2=A0 random_pages =3D get_random_long() % total_user_pa=
ges;
>> +=C2=A0=C2=A0=C2=A0 random_vaddr =3D FIRST_USER_ADDRESS + random_pages=
 * PAGE_SIZE;
>> +
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(random_vaddr > TASK_SIZE);
>> +=C2=A0=C2=A0=C2=A0 WARN_ON(random_vaddr < FIRST_USER_ADDRESS);
>> +=C2=A0=C2=A0=C2=A0 return random_vaddr;
>> +}
>> +
>> +static int __init arch_pgtable_tests_init(void)
>> +{
>> +=C2=A0=C2=A0=C2=A0 struct mm_struct *mm;
>> +=C2=A0=C2=A0=C2=A0 struct page *page;
>> +=C2=A0=C2=A0=C2=A0 pgd_t *pgdp;
>> +=C2=A0=C2=A0=C2=A0 p4d_t *p4dp, *saved_p4dp;
>> +=C2=A0=C2=A0=C2=A0 pud_t *pudp, *saved_pudp;
>> +=C2=A0=C2=A0=C2=A0 pmd_t *pmdp, *saved_pmdp, pmd;
>> +=C2=A0=C2=A0=C2=A0 pte_t *ptep;
>> +=C2=A0=C2=A0=C2=A0 pgtable_t saved_ptep;
>> +=C2=A0=C2=A0=C2=A0 pgprot_t prot;
>> +=C2=A0=C2=A0=C2=A0 unsigned long vaddr;
>> +
>> +=C2=A0=C2=A0=C2=A0 prot =3D vm_get_page_prot(VMFLAGS);
>> +=C2=A0=C2=A0=C2=A0 vaddr =3D get_random_vaddr();
>> +=C2=A0=C2=A0=C2=A0 mm =3D mm_alloc();
>> +=C2=A0=C2=A0=C2=A0 if (!mm) {
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pr_err("mm_struct allocati=
on failed\n");
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return 1;
>> +=C2=A0=C2=A0=C2=A0 }
>> +
>> +=C2=A0=C2=A0=C2=A0 page =3D alloc_mapped_page();
>> +=C2=A0=C2=A0=C2=A0 if (!page) {
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pr_err("memory allocation =
failed\n");
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return 1;
>> +=C2=A0=C2=A0=C2=A0 }
>> +
>> +=C2=A0=C2=A0=C2=A0 pgdp =3D pgd_offset(mm, vaddr);
>> +=C2=A0=C2=A0=C2=A0 p4dp =3D p4d_alloc(mm, pgdp, vaddr);
>> +=C2=A0=C2=A0=C2=A0 pudp =3D pud_alloc(mm, p4dp, vaddr);
>> +=C2=A0=C2=A0=C2=A0 pmdp =3D pmd_alloc(mm, pudp, vaddr);
>> +=C2=A0=C2=A0=C2=A0 ptep =3D pte_alloc_map(mm, pmdp, vaddr);
>> +
>> +=C2=A0=C2=A0=C2=A0 /*
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * Save all the page table page addresses as =
the page table
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * entries will be used for testing with rand=
om or garbage
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * values. These saved addresses will be used=
 for freeing
>> +=C2=A0=C2=A0=C2=A0=C2=A0 * page table pages.
>> +=C2=A0=C2=A0=C2=A0=C2=A0 */
>> +=C2=A0=C2=A0=C2=A0 pmd =3D READ_ONCE(*pmdp);
>> +=C2=A0=C2=A0=C2=A0 saved_p4dp =3D p4d_offset(pgdp, 0UL);
>> +=C2=A0=C2=A0=C2=A0 saved_pudp =3D pud_offset(p4dp, 0UL);
>> +=C2=A0=C2=A0=C2=A0 saved_pmdp =3D pmd_offset(pudp, 0UL);
>> +=C2=A0=C2=A0=C2=A0 saved_ptep =3D pmd_pgtable(pmd);
>> +
>> +=C2=A0=C2=A0=C2=A0 pte_basic_tests(page, prot);
>> +=C2=A0=C2=A0=C2=A0 pmd_basic_tests(page, prot);
>> +=C2=A0=C2=A0=C2=A0 pud_basic_tests(page, prot);
>> +=C2=A0=C2=A0=C2=A0 p4d_basic_tests(page, prot);
>> +=C2=A0=C2=A0=C2=A0 pgd_basic_tests(page, prot);
>> +
>> +=C2=A0=C2=A0=C2=A0 pte_clear_tests(mm, ptep);
>> +=C2=A0=C2=A0=C2=A0 pmd_clear_tests(pmdp);
>> +=C2=A0=C2=A0=C2=A0 pud_clear_tests(pudp);
>> +=C2=A0=C2=A0=C2=A0 p4d_clear_tests(p4dp);
>> +=C2=A0=C2=A0=C2=A0 pgd_clear_tests(mm, pgdp);
>> +
>> +=C2=A0=C2=A0=C2=A0 pmd_populate_tests(mm, pmdp, saved_ptep);
>> +=C2=A0=C2=A0=C2=A0 pud_populate_tests(mm, pudp, saved_pmdp);
>> +=C2=A0=C2=A0=C2=A0 p4d_populate_tests(mm, p4dp, saved_pudp);
>> +=C2=A0=C2=A0=C2=A0 pgd_populate_tests(mm, pgdp, saved_p4dp);
>> +
>> +=C2=A0=C2=A0=C2=A0 p4d_free(mm, saved_p4dp);
>> +=C2=A0=C2=A0=C2=A0 pud_free(mm, saved_pudp);
>> +=C2=A0=C2=A0=C2=A0 pmd_free(mm, saved_pmdp);
>> +=C2=A0=C2=A0=C2=A0 pte_free(mm, saved_ptep);
>> +
>> +=C2=A0=C2=A0=C2=A0 mm_dec_nr_puds(mm);
>> +=C2=A0=C2=A0=C2=A0 mm_dec_nr_pmds(mm);
>> +=C2=A0=C2=A0=C2=A0 mm_dec_nr_ptes(mm);
>> +=C2=A0=C2=A0=C2=A0 __mmdrop(mm);
>> +
>> +=C2=A0=C2=A0=C2=A0 free_mapped_page(page);
>> +=C2=A0=C2=A0=C2=A0 return 0;
>> +}
>> +
>> +static void __exit arch_pgtable_tests_exit(void) { }
>> +
>> +module_init(arch_pgtable_tests_init);
>> +module_exit(arch_pgtable_tests_exit);
>> +
>> +MODULE_LICENSE("GPL v2");
>> +MODULE_AUTHOR("Anshuman Khandual <anshuman.khandual@arm.com>");
>> +MODULE_DESCRIPTION("Test architecture page table helpers");
>>

