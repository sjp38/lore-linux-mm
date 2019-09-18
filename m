Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B8FDC4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 05:04:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FEFC21848
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 05:04:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FEFC21848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF7116B0279; Wed, 18 Sep 2019 01:04:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B80ED6B027A; Wed, 18 Sep 2019 01:04:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4A7B6B027B; Wed, 18 Sep 2019 01:04:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0011.hostedemail.com [216.40.44.11])
	by kanga.kvack.org (Postfix) with ESMTP id 7B83E6B0279
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 01:04:08 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 20C5F180AD806
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 05:04:08 +0000 (UTC)
X-FDA: 75946849776.26.angle90_6d2603d21062
X-HE-Tag: angle90_6d2603d21062
X-Filterd-Recvd-Size: 10853
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 05:04:06 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7351F1000;
	Tue, 17 Sep 2019 22:04:05 -0700 (PDT)
Received: from [10.162.40.136] (p8cg001049571a15.blr.arm.com [10.162.40.136])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B280D3F575;
	Tue, 17 Sep 2019 22:03:54 -0700 (PDT)
Subject: Re: [PATCH V2 2/2] mm/pgtable/debug: Add test validating architecture
 page table helpers
To: Christophe Leroy <christophe.leroy@c-s.fr>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
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
 Ralf Baechle <ralf@linux-mips.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>,
 Gerald Schaefer <gerald.schaefer@de.ibm.com>,
 linux-snps-arc@lists.infradead.org, linux-mips@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 linux-kernel@vger.kernel.org
References: <1568268173-31302-1-git-send-email-anshuman.khandual@arm.com>
 <1568268173-31302-3-git-send-email-anshuman.khandual@arm.com>
 <ab0ca38b-1e4f-b636-f8b4-007a15903984@c-s.fr>
 <502c497a-9bf1-7d2e-95f2-cfebcd9cf1d9@arm.com>
 <95ed9d92-dd43-4c45-2e52-738aed7f2fb5@c-s.fr>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <f872e6f4-a5cb-069d-2034-78961930cb9f@arm.com>
Date: Wed, 18 Sep 2019 10:34:09 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <95ed9d92-dd43-4c45-2e52-738aed7f2fb5@c-s.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 09/13/2019 03:31 PM, Christophe Leroy wrote:
>=20
>=20
> Le 13/09/2019 =C3=A0 11:02, Anshuman Khandual a =C3=A9crit=C2=A0:
>>
>>>> +#if !defined(__PAGETABLE_PMD_FOLDED) && !defined(__ARCH_HAS_4LEVEL_=
HACK)
>>>
>>> #ifdefs have to be avoided as much as possible, see below
>>
>> Yeah but it has been bit difficult to avoid all these $ifdef because o=
f the
>> availability (or lack of it) for all these pgtable helpers in various =
config
>> combinations on all platforms.
>=20
> As far as I can see these pgtable helpers should exist everywhere at le=
ast via asm-generic/ files.

But they might not actually do the right thing.

>=20
> Can you spot a particular config which fails ?

Lets consider the following example (after removing the $ifdefs around it=
)
which though builds successfully but fails to pass the intended test. Thi=
s
is with arm64 config 4K pages sizes with 39 bits VA space which ends up
with a 3 level page table arrangement.

static void __init p4d_clear_tests(p4d_t *p4dp)
{
        p4d_t p4d =3D READ_ONCE(*p4dp);

        p4d =3D __p4d(p4d_val(p4d) | RANDOM_ORVALUE);
        WRITE_ONCE(*p4dp, p4d);
        p4d_clear(p4dp);
        p4d =3D READ_ONCE(*p4dp);
        WARN_ON(!p4d_none(p4d));
}

The following test hits an error at WARN_ON(!p4d_none(p4d))

[   16.757333] ------------[ cut here ]------------
[   16.758019] WARNING: CPU: 11 PID: 1 at mm/arch_pgtable_test.c:187 arch=
_pgtable_tests_init+0x24c/0x474
[   16.759455] Modules linked in:
[   16.759952] CPU: 11 PID: 1 Comm: swapper/0 Not tainted 5.3.0-next-2019=
0916-00005-g61c218153bb8-dirty #222
[   16.761449] Hardware name: linux,dummy-virt (DT)
[   16.762185] pstate: 00400005 (nzcv daif +PAN -UAO)
[   16.762964] pc : arch_pgtable_tests_init+0x24c/0x474
[   16.763750] lr : arch_pgtable_tests_init+0x174/0x474
[   16.764534] sp : ffffffc011d7bd50
[   16.765065] x29: ffffffc011d7bd50 x28: ffffffff1756bac0=20
[   16.765908] x27: ffffff85ddaf3000 x26: 00000000000002e8=20
[   16.766767] x25: ffffffc0111ce000 x24: ffffff85ddaf32e8=20
[   16.767606] x23: ffffff85ddaef278 x22: 00000045cc844000=20
[   16.768445] x21: 000000065daef003 x20: ffffffff17540000=20
[   16.769283] x19: ffffff85ddb60000 x18: 0000000000000014=20
[   16.770122] x17: 00000000980426bb x16: 00000000698594c6=20
[   16.770976] x15: 0000000066e25a88 x14: 0000000000000000=20
[   16.771813] x13: ffffffff17540000 x12: 000000000000000a=20
[   16.772651] x11: ffffff85fcfd0a40 x10: 0000000000000001=20
[   16.773488] x9 : 0000000000000008 x8 : ffffffc01143ab26=20
[   16.774336] x7 : 0000000000000000 x6 : 0000000000000000=20
[   16.775180] x5 : 0000000000000000 x4 : 0000000000000000=20
[   16.776018] x3 : ffffffff1756bbe8 x2 : 000000065daeb003=20
[   16.776856] x1 : 000000000065daeb x0 : fffffffffffff000=20
[   16.777693] Call trace:
[   16.778092]  arch_pgtable_tests_init+0x24c/0x474
[   16.778843]  do_one_initcall+0x74/0x1b0
[   16.779458]  kernel_init_freeable+0x1cc/0x290
[   16.780151]  kernel_init+0x10/0x100
[   16.780710]  ret_from_fork+0x10/0x18
[   16.781282] ---[ end trace 042e6c40c0a3b038 ]---

On arm64 (4K page size|39 bits VA|3 level page table)

#elif CONFIG_PGTABLE_LEVELS =3D=3D 3	/* Applicable here */
#define __ARCH_USE_5LEVEL_HACK
#include <asm-generic/pgtable-nopud.h>

Which pulls in=20

#include <asm-generic/pgtable-nop4d-hack.h>

which pulls in

#include <asm-generic/5level-fixup.h>

which defines

static inline int p4d_none(p4d_t p4d)
{
        return 0;
}

which will invariably trigger WARN_ON(!p4d_none(p4d)).

Similarly for next test p4d_populate_tests() which will always be
successful because p4d_bad() invariably returns negative.

static inline int p4d_bad(p4d_t p4d)
{
        return 0;
}

static void __init p4d_populate_tests(struct mm_struct *mm, p4d_t *p4dp,
                                      pud_t *pudp)
{
        p4d_t p4d;

        /*
         * This entry points to next level page table page.
         * Hence this must not qualify as p4d_bad().
         */
        pud_clear(pudp);
        p4d_clear(p4dp);
        p4d_populate(mm, p4dp, pudp);
        p4d =3D READ_ONCE(*p4dp);
        WARN_ON(p4d_bad(p4d));
}

We should not run these tests for the above config because they are
not applicable and will invariably produce same result.

>=20
>>
>>>
>=20
> [...]
>=20
>>>> +#if !defined(__PAGETABLE_PUD_FOLDED) && !defined(__ARCH_HAS_5LEVEL_=
HACK)
>>>
>>> The same can be done here.
>>
>> IIRC not only the page table helpers but there are data types (pxx_t) =
which
>> were not present on various configs and these wrappers help prevent bu=
ild
>> failures. Any ways will try and see if this can be improved further. B=
ut
>> meanwhile if you have some suggestions, please do let me know.
>=20
> pgt_t and pmd_t are everywhere I guess.
> then pud_t and p4d_t have fallbacks in asm-generic files.

Lets take another example where it fails to compile. On arm64 with 16K
page size, 48 bits VA, 4 level page table arrangement in the following
test, pgd_populate() does not have the required signature.

static void pgd_populate_tests(struct mm_struct *mm, pgd_t *pgdp, p4d_t *=
p4dp)
{
        pgd_t pgd;

        if (mm_p4d_folded(mm))
                return;

       /*
         * This entry points to next level page table page.
         * Hence this must not qualify as pgd_bad().
         */
        p4d_clear(p4dp);
        pgd_clear(pgdp);
        pgd_populate(mm, pgdp, p4dp);
        pgd =3D READ_ONCE(*pgdp);
        WARN_ON(pgd_bad(pgd));
}

mm/arch_pgtable_test.c: In function =E2=80=98pgd_populate_tests=E2=80=99:
mm/arch_pgtable_test.c:254:25: error: passing argument 3 of =E2=80=98pgd_=
populate=E2=80=99 from incompatible pointer type [-Werror=3Dincompatible-=
pointer-types]
  pgd_populate(mm, pgdp, p4dp);
                         ^~~~
In file included from mm/arch_pgtable_test.c:27:0:
./arch/arm64/include/asm/pgalloc.h:81:20: note: expected =E2=80=98pud_t *=
 {aka struct <anonymous> *}=E2=80=99 but argument is of type =E2=80=98pgd=
_t * {aka struct <anonymous> *}=E2=80=99
 static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgdp, pud_t=
 *pudp)

The build failure is because p4d_t * maps to pgd_t * but the applicable
(it does not fallback on generic ones) pgd_populate() expects a pud_t *.

Except for archs which have 5 level page able, pgd_populate() always acce=
pts
lower level page table pointers as the last argument as they dont have th=
at
many levels.

arch/x86/include/asm/pgalloc.h:static inline void pgd_populate(struct mm_=
struct *mm, pgd_t *pgd, p4d_t *p4d)
arch/s390/include/asm/pgalloc.h:static inline void pgd_populate(struct mm=
_struct *mm, pgd_t *pgd, p4d_t *p4d)

But others

arch/arm64/include/asm/pgalloc.h:static inline void pgd_populate(struct m=
m_struct *mm, pgd_t *pgdp, pud_t *pudp)
arch/m68k/include/asm/motorola_pgalloc.h:static inline void pgd_populate(=
struct mm_struct *mm, pgd_t *pgd, pmd_t *pmd)
arch/mips/include/asm/pgalloc.h:static inline void pgd_populate(struct mm=
_struct *mm, pgd_t *pgd, pud_t *pud)
arch/powerpc/include/asm/book3s/64/pgalloc.h:static inline void pgd_popul=
ate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)

I remember going through all these combinations before arriving at the
current state of #ifdef exclusions. Probably, to solved this all platform=
s
have to define pxx_populate() helpers assuming they support 5 level page
table.

>=20
> So it shouldn't be an issue. Maybe if a couple of arches miss them, the=
 best would be to fix the arches, since that's the purpose of your testsu=
ite isn't it ?

The run time failures as explained previously is because of the folding w=
hich
needs to be protected as they are not even applicable. The compile time
failures are because pxx_populate() signatures are platform specific depe=
nding
on how many page table levels they really support.

