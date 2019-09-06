Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8CC4C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 07:03:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DCE821D7C
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 07:03:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DCE821D7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2949A6B0007; Fri,  6 Sep 2019 03:03:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 245746B0008; Fri,  6 Sep 2019 03:03:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10D596B000A; Fri,  6 Sep 2019 03:03:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0245.hostedemail.com [216.40.44.245])
	by kanga.kvack.org (Postfix) with ESMTP id E07F16B0007
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 03:03:22 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 8F84A4857
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 07:03:22 +0000 (UTC)
X-FDA: 75903604644.10.able49_3a3caa347035a
X-HE-Tag: able49_3a3caa347035a
X-Filterd-Recvd-Size: 8776
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 07:03:20 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 05E0E28;
	Fri,  6 Sep 2019 00:03:19 -0700 (PDT)
Received: from [10.162.42.101] (p8cg001049571a15.blr.arm.com [10.162.42.101])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B8A783F67D;
	Fri,  6 Sep 2019 00:05:32 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH 1/1] mm/pgtable/debug: Add test validating architecture
 page table helpers
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 Vlastimil Babka <vbabka@suse.cz>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Thomas Gleixner <tglx@linutronix.de>, Mike Rapoport
 <rppt@linux.vnet.ibm.com>, Jason Gunthorpe <jgg@ziepe.ca>,
 Dan Williams <dan.j.williams@intel.com>,
 Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@kernel.org>,
 Mark Rutland <mark.rutland@arm.com>, Mark Brown <broonie@kernel.org>,
 Steven Price <Steven.Price@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Kees Cook <keescook@chromium.org>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Matthew Wilcox <willy@infradead.org>,
 Sri Krishna chowdary <schowdary@nvidia.com>,
 Dave Hansen <dave.hansen@intel.com>,
 Russell King - ARM Linux <linux@armlinux.org.uk>,
 Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 "David S. Miller" <davem@davemloft.net>, Vineet Gupta <vgupta@synopsys.com>,
 James Hogan <jhogan@kernel.org>, Paul Burton <paul.burton@mips.com>,
 Ralf Baechle <ralf@linux-mips.org>, linux-snps-arc@lists.infradead.org,
 linux-mips@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 sparclinux@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org
References: <1567497706-8649-1-git-send-email-anshuman.khandual@arm.com>
 <1567497706-8649-2-git-send-email-anshuman.khandual@arm.com>
 <20190904141950.ykoe3h7b4hcvnysu@box>
 <6d4b989d-8eaa-d26e-6068-4b0e4d7a52f9@arm.com>
 <20190905085910.i6dppgnqi4ple22w@box.shutemov.name>
Message-ID: <9c226f84-fe8f-8438-b378-b6659cccfcd1@arm.com>
Date: Fri, 6 Sep 2019 12:33:14 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190905085910.i6dppgnqi4ple22w@box.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 09/05/2019 02:29 PM, Kirill A. Shutemov wrote:
> On Thu, Sep 05, 2019 at 01:48:27PM +0530, Anshuman Khandual wrote:
>>>> +#define VADDR_TEST	(PGDIR_SIZE + PUD_SIZE + PMD_SIZE + PAGE_SIZE)
>>>
>>> What is special about this address? How do you know if it is not occu=
pied
>>> yet?
>>
>> We are creating the page table from scratch after allocating an mm_str=
uct
>> for a given random virtual address 'VADDR_TEST'. Hence nothing is occu=
pied
>> just yet. There is nothing special about this address, just that it tr=
ies
>> to ensure the page table entries are being created with some offset fr=
om
>> beginning of respective page table page at all levels ? The idea is to
>> have a more representative form of page table structure for test.
>=20
> Why P4D_SIZE is missing?

That was an omission even though I was wondering whether it will be
applicable or even make sense on platforms which dont have real P4D.

>=20
> Are you sure it will not land into kernel address space on any arch?

Can it even cross user virtual address range with just a single span
at each page table level ? TBH I did not think about that possibility.

>=20
> I think more robust way to deal with this would be using
> get_unmapped_area() instead of fixed address.

Makes sense and probably its better to get a virtual address which
is known to have been checked against all boundary conditions. Will
explore around get_unmapped_area() in this regard.

>=20
>> This makes sense for runtime cases but there is a problem here.
>>
>> On arm64, pgd_populate() which takes (pud_t *) as last argument instea=
d of
>> (p4d_t *) will fail to build when not wrapped in !__PAGETABLE_P4D_FOLD=
ED
>> on certain configurations.
>>
>> ./arch/arm64/include/asm/pgalloc.h:81:75: note:
>> expected =E2=80=98pud_t *=E2=80=99 {aka =E2=80=98struct <anonymous> *=E2=
=80=99}
>> but argument is of type =E2=80=98pgd_t *=E2=80=99 {aka =E2=80=98struct=
 <anonymous> *=E2=80=99}
>> static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgdp, pud=
_t *pudp)
>>                                                                    ~~~=
~~~~^~~~
>> Wondering if this is something to be fixed on arm64 or its more genera=
l
>> problem. Will look into this further.
>=20
> I think you need wrap this into #ifndef __ARCH_HAS_5LEVEL_HACK.

Okay.

>=20
>>>> +	pmd_populate_tests(mm, pmdp, (pgtable_t) page);
>>>
>>> This is not correct for architectures that defines pgtable_t as pte_t
>>> pointer, not struct page pointer.
>>
>> Right, a grep on the source confirms that.
>>
>> These platforms define pgtable_t as struct page *
>>
>> arch/alpha/include/asm/page.h:typedef struct page *pgtable_t;
>> arch/arm/include/asm/page.h:typedef struct page *pgtable_t;
>> arch/arm64/include/asm/page.h:typedef struct page *pgtable_t;
>> arch/csky/include/asm/page.h:typedef struct page *pgtable_t;
>> arch/hexagon/include/asm/page.h:typedef struct page *pgtable_t;
>> arch/ia64/include/asm/page.h:  typedef struct page *pgtable_t;
>> arch/ia64/include/asm/page.h:    typedef struct page *pgtable_t;
>> arch/m68k/include/asm/page.h:typedef struct page *pgtable_t;
>> arch/microblaze/include/asm/page.h:typedef struct page *pgtable_t;
>> arch/mips/include/asm/page.h:typedef struct page *pgtable_t;
>> arch/nds32/include/asm/page.h:typedef struct page *pgtable_t;
>> arch/nios2/include/asm/page.h:typedef struct page *pgtable_t;
>> arch/openrisc/include/asm/page.h:typedef struct page *pgtable_t;
>> arch/parisc/include/asm/page.h:typedef struct page *pgtable_t;
>> arch/riscv/include/asm/page.h:typedef struct page *pgtable_t;
>> arch/sh/include/asm/page.h:typedef struct page *pgtable_t;
>> arch/sparc/include/asm/page_32.h:typedef struct page *pgtable_t;
>> arch/um/include/asm/page.h:typedef struct page *pgtable_t;
>> arch/unicore32/include/asm/page.h:typedef struct page *pgtable_t;
>> arch/x86/include/asm/pgtable_types.h:typedef struct page *pgtable_t;
>> arch/xtensa/include/asm/page.h:typedef struct page *pgtable_t;
>>
>> These platforms define pgtable_t as pte_t *
>>
>> arch/arc/include/asm/page.h:typedef pte_t * pgtable_t;
>> arch/powerpc/include/asm/mmu.h:typedef pte_t *pgtable_t;
>> arch/s390/include/asm/page.h:typedef pte_t *pgtable_t;
>> arch/sparc/include/asm/page_64.h:typedef pte_t *pgtable_t;
>>
>> Should we need have two pmd_populate_tests() definitions with
>> different arguments (struct page pointer or pte_t pointer) and then
>> call either one after detecting the given platform ?
>=20
> Use pte_alloc_one() instead of alloc_mapped_page() to allocate the page
> table.

Right, the PTE page table page should come from pte_alloc_one() instead
directly from a struct page. The functions pte_alloc_one() and pte_free()
operate on (struct page or pte_t) pointers depending applicable pgtable_t
definition (in cases where platform defines otherwise). Will fix it.

>=20
>>>> +	pud_populate_tests(mm, pudp, pmdp);
>>>> +	p4d_populate_tests(mm, p4dp, pudp);
>>>> +	pgd_populate_tests(mm, pgdp, p4dp);
>>>
>>> This is wrong. All p?dp points to the second entry in page table entr=
y.
>>> This is not valid pointer for page table and triggers p?d_bad() on x8=
6.
>>
>> Yeah these are second entries because of the way we create the page ta=
ble.
>> But I guess its applicable only to the second argument in all these ab=
ove
>> cases because the first argument can be any valid entry on previous pa=
ge
>> table level.
>=20
> Yes:
>=20
> @@ -397,9 +396,9 @@ static int __init arch_pgtable_tests_init(void)
>  	pgd_clear_tests(pgdp);
> =20
>  	pmd_populate_tests(mm, pmdp, (pgtable_t) page);
> -	pud_populate_tests(mm, pudp, pmdp);
> -	p4d_populate_tests(mm, p4dp, pudp);
> -	pgd_populate_tests(mm, pgdp, p4dp);
> +	pud_populate_tests(mm, pudp, saved_pmdp);
> +	p4d_populate_tests(mm, p4dp, saved_pudp);
> +	pgd_populate_tests(mm, pgdp, saved_p4dp);

Sure.

