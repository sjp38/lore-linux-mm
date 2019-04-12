Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,MIME_QP_LONG_LINE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24935C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 17:14:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE656218AF
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 17:14:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="yDBcMbfj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE656218AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F45E6B000D; Fri, 12 Apr 2019 13:14:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A4FF6B0010; Fri, 12 Apr 2019 13:14:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3938B6B026A; Fri, 12 Apr 2019 13:14:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id F037E6B000D
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 13:14:53 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id q18so6628456pll.16
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 10:14:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=T0RfYfVFPO2wCvsTNYwOuR0FeTSbs1A8vdXsewe4BN4=;
        b=Iq8ijpEMjB82062L9sqq5kDzaQpT63W7TucBEnakNmQSu5Bb2ChAeekZdLkTS2iioP
         K23wfW1YRGRGBqaXg7RLrVi/6Ck44imu+tkh4BZaH8wbjXXG6sulnFS5XoLnFjCuQ8RA
         7Vc+Kwr3FgI+A6YVaClzNCaNvSDWLJGxcTB21J1CrMQqjzMj5DmkAlFc1NymH4O7br1P
         sqhgfFGIzpN1U07xHNQucKC8m7dbLNybVnmbwStiwR+hhkr82F4zWx84m1DLmx4gI1r3
         deEqejJbtS6L52SNukaXYGXbdif9ps88HQyuH6TI8x+QwwrQy9GxSrt7gU5EyWEz3wCZ
         Td3w==
X-Gm-Message-State: APjAAAUxF3ZqlENjUMAJb4Y2KhBsEbtn+oBEYS85MWUdyBMc8xsuHGuQ
	Kk3yc+cnuXjaiX3Vq3fMoJE0wxm0NfuMwRuH7i3ojponTzcTpBcvMEsVrF9kfC22bry09+wPsq3
	New/BpMhVrv/VWxAUPfaL7kgaftSgOkoe1T1QHpJfP2jPieBP8C/JeBnvzGoAZ5cjCQ==
X-Received: by 2002:a17:902:b489:: with SMTP id y9mr50109430plr.17.1555089293434;
        Fri, 12 Apr 2019 10:14:53 -0700 (PDT)
X-Received: by 2002:a17:902:b489:: with SMTP id y9mr50109342plr.17.1555089292475;
        Fri, 12 Apr 2019 10:14:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555089292; cv=none;
        d=google.com; s=arc-20160816;
        b=0xVwEEKBQzte4KlDTbGH16Qm1oxwFktUQc0UPIMBdkoPFO7Rv3wpccCdLV7cgPIIZ4
         PnKDX3LFCtCrCqW3L9BeQF6uEbY9p2+yPOcCsOt8DMCAvbLXhXLC52ZErYiEcKuP2GKI
         QcVCAlmwheh+RapU/a7n/FECxZdNrrpFtSmd0Om5w8e3xQW3/B69K0QA3MVzZBVe1Irq
         Ixg4A7Mhkuky/RnK7SKhRD6ga2S30x3sKbiXzOmhieo303kNaq/2x+xJGUAmpkut/ebe
         1WDpjyZR4lscVJiZx3CfZzmYOWosnIL4VzszcOr8qvC+hJJ1kOhsLJCDnJINvXGCg/w/
         /IGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=T0RfYfVFPO2wCvsTNYwOuR0FeTSbs1A8vdXsewe4BN4=;
        b=POatyYzzkJ6FoUD5QLr7AIz8N6lWMVI44NjMmq3sJ/qWIFeZz8B++IiXqMAJgCeDVH
         XbDvu9QTiQdtVJtL1RFS04rPvo9zP1pLQLkiKrmStb7VtcXDhts72Y+mxXejBEMKxGoe
         RIWzpRw8zkf2EzLEHmy2+F4+zX9C9zpqkwqpv9h8zxhTFzaOQBc4hMGdROnB66WR1Sk4
         rFYpf/GjisudMcm6pERbm4Uw+bNpL7+Dkp/ncbYh0Vgg5O8RlLUTvMQu41pLTXvnc6C2
         Wg1U5jYKcdhfv5hk7qNFFSi9GsgFcSgr2rXiT64E0VlwugeBKOdX1XU5fZdRQdFMWMMc
         gzgw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=yDBcMbfj;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n78sor14310446pfi.4.2019.04.12.10.14.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 10:14:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=yDBcMbfj;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=T0RfYfVFPO2wCvsTNYwOuR0FeTSbs1A8vdXsewe4BN4=;
        b=yDBcMbfjcR3LJR+LPmSN2beqV5RRaoHBfP/MSIAzfjfktd+Uz08tfQEfQpYX5qSoGH
         D7HfCYAgTkTgRWSQOvX1Ewi0FoARBjltfRbAOafFuHaTQKfQyUWRDw/evMzcDeUuUsRu
         Siyolx+cjAQjdxcJuhddsVkUSbBe386WZSgDmtExoc6XQetPybpp0RWQAP3n+yGw6s9t
         tiwzYV5+uKC0mHr0GpdTu9aEFkpaZuu1wC6sVHsOzeAPQ7GEetAH9j43PoptEpqr9jXg
         g3tCPB/9NlXVfRVr5Z2tH8hSPaBeiwSYa4ZKNNbWT5xz0ZH+CeTv0rzRTs/9DJOr5XxC
         T6Zw==
X-Google-Smtp-Source: APXvYqwna1GD6+18LTgcY86tbFyMtotwuQplFrXdbFrHUHZZzC481ZWK63Ct5VW7tLDqzRGVHqL22Q==
X-Received: by 2002:aa7:820c:: with SMTP id k12mr57439722pfi.177.1555089292037;
        Fri, 12 Apr 2019 10:14:52 -0700 (PDT)
Received: from ?IPv6:2601:646:c200:1ef2:a0a3:bf36:c93b:c6fb? ([2601:646:c200:1ef2:a0a3:bf36:c93b:c6fb])
        by smtp.gmail.com with ESMTPSA id q75sm25345933pfi.102.2019.04.12.10.14.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 10:14:50 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: 1808d65b55 ("asm-generic/tlb: Remove arch_tlb*_mmu()"):  BUG: KASAN: stack-out-of-bounds in __change_page_attr_set_clr
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16D57)
In-Reply-To: <E33FDED8-8B95-431D-9AC7-71D45AB49011@vmware.com>
Date: Fri, 12 Apr 2019 10:14:49 -0700
Cc: Peter Zijlstra <peterz@infradead.org>,
 kernel test robot <lkp@intel.com>, LKP <lkp@01.org>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>,
 Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>,
 Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@kernel.org>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Dave Hansen <dave.hansen@intel.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <43ACD9F9-6373-4325-A97A-B8E8588E24BD@amacapital.net>
References: <5cae03c4.iIPk2cWlfmzP0Zgy%lkp@intel.com> <20190411193906.GA12232@hirez.programming.kicks-ass.net> <20190411195424.GL14281@hirez.programming.kicks-ass.net> <20190411211348.GA8451@worktop.programming.kicks-ass.net> <20190412105633.GM14281@hirez.programming.kicks-ass.net> <20190412111756.GO14281@hirez.programming.kicks-ass.net> <F18AF0D5-D8B4-4F4B-8469-F9DEC49683C7@vmware.com> <E33FDED8-8B95-431D-9AC7-71D45AB49011@vmware.com>
To: Nadav Amit <namit@vmware.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On Apr 12, 2019, at 10:05 AM, Nadav Amit <namit@vmware.com> wrote:

>> On Apr 12, 2019, at 8:11 AM, Nadav Amit <namit@vmware.com> wrote:
>>=20
>>> On Apr 12, 2019, at 4:17 AM, Peter Zijlstra <peterz@infradead.org> wrote=
:
>>>=20
>>> On Fri, Apr 12, 2019 at 12:56:33PM +0200, Peter Zijlstra wrote:
>>>>> On Thu, Apr 11, 2019 at 11:13:48PM +0200, Peter Zijlstra wrote:
>>>>>> On Thu, Apr 11, 2019 at 09:54:24PM +0200, Peter Zijlstra wrote:
>>>>>>> On Thu, Apr 11, 2019 at 09:39:06PM +0200, Peter Zijlstra wrote:
>>>>>>> I think this bisect is bad. If you look at your own logs this patch
>>>>>>> merely changes the failure, but doesn't make it go away.
>>>>>>>=20
>>>>>>> Before this patch (in fact, before tip/core/mm entirely) the errror
>>>>>>> reads like the below, which suggests there is memory corruption
>>>>>>> somewhere, and the fingered patch just makes it trigger differently.=

>>>>>>>=20
>>>>>>> It would be very good to find the source of this corruption, but I'm=

>>>>>>> fairly certain it is not here.
>>>>>>=20
>>>>>> I went back to v4.20 to try and find a time when the below error did n=
ot
>>>>>> occur, but even that reliably triggers the warning.
>>>>>=20
>>>>> So I also tested v4.19 and found that that was good, which made me
>>>>> bisect v4.19..v4.20
>>>>>=20
>>>>> # bad: [8fe28cb58bcb235034b64cbbb7550a8a43fd88be] Linux 4.20
>>>>> # good: [84df9525b0c27f3ebc2ebb1864fa62a97fdedb7d] Linux 4.19
>>>>> git bisect start 'v4.20' 'v4.19'
>>>>> # bad: [ec9c166434595382be3babf266febf876327774d] Merge tag 'mips_fixe=
s_4.20_1' of git://git.kernel.org/pub/scm/linux/kernel/git/mips/linux
>>>>> git bisect bad ec9c166434595382be3babf266febf876327774d
>>>>> # bad: [50b825d7e87f4cff7070df6eb26390152bb29537] Merge git://git.kern=
el.org/pub/scm/linux/kernel/git/davem/net-next
>>>>> git bisect bad 50b825d7e87f4cff7070df6eb26390152bb29537
>>>>> # good: [99e9acd85ccbdc8f5785f9e961d4956e96bd6aa5] Merge tag 'mlx5-upd=
ates-2018-10-17' of git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linu=
x
>>>>> git bisect good 99e9acd85ccbdc8f5785f9e961d4956e96bd6aa5
>>>>> # good: [c403993a41d50db1e7d9bc2d43c3c8498162312f] Merge tag 'for-linu=
s-4.20' of https://nam04.safelinks.protection.outlook.com/?url=3Dhttps%3A%2F%=
2Fgithub.com%2Fcminyard%2Flinux-ipmi&amp;data=3D02%7C01%7Cnamit%40vmware.com=
%7Ca1c3ea5d4bc34cfc785508d6bf388ff3%7Cb39138ca3cee4b4aa4d6cd83d9dd62f0%7C0%7=
C0%7C636906647013777573&amp;sdata=3D3VSR3VdE5rxOitAdkqFNPpAnAtLgDmYLzJtoUrs5=
v9Y%3D&amp;reserved=3D0
>>>>> git bisect good c403993a41d50db1e7d9bc2d43c3c8498162312f
>>>>> # good: [c05f3642f4304dd081876e77a68555b6aba4483f] Merge branch 'perf-=
core-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
>>>>> git bisect good c05f3642f4304dd081876e77a68555b6aba4483f
>>>>> # bad: [44786880df196a4200c178945c4d41675faf9fb7] Merge branch 'parisc=
-4.20-1' of git://git.kernel.org/pub/scm/linux/kernel/git/deller/parisc-linu=
x
>>>>> git bisect bad 44786880df196a4200c178945c4d41675faf9fb7
>>>>> # bad: [99792e0cea1ed733cdc8d0758677981e0cbebfed] Merge branch 'x86-mm=
-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
>>>>> git bisect bad 99792e0cea1ed733cdc8d0758677981e0cbebfed
>>>>> # good: [fec98069fb72fb656304a3e52265e0c2fc9adf87] Merge branch 'x86-c=
pu-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
>>>>> git bisect good fec98069fb72fb656304a3e52265e0c2fc9adf87
>>>>> # bad: [a31acd3ee8f7dbc0370bdf4a4bfef7a8c13c7542] x86/mm: Page size aw=
are flush_tlb_mm_range()
>>>>> git bisect bad a31acd3ee8f7dbc0370bdf4a4bfef7a8c13c7542
>>>>> # good: [a7295fd53c39ce781a9792c9dd2c8747bf274160] x86/mm/cpa: Use flu=
sh_tlb_kernel_range()
>>>>> git bisect good a7295fd53c39ce781a9792c9dd2c8747bf274160
>>>>> # good: [9cf38d5559e813cccdba8b44c82cc46ba48d0896] kexec: Allocate dec=
rypted control pages for kdump if SME is enabled
>>>>> git bisect good 9cf38d5559e813cccdba8b44c82cc46ba48d0896
>>>>> # good: [5b12904065798fee8b153a506ac7b72d5ebbe26c] x86/mm/doc: Clean u=
p the x86-64 virtual memory layout descriptions
>>>>> git bisect good 5b12904065798fee8b153a506ac7b72d5ebbe26c
>>>>> # good: [cf089611f4c446285046fcd426d90c18f37d2905] proc/vmcore: Fix i3=
86 build error of missing copy_oldmem_page_encrypted()
>>>>> git bisect good cf089611f4c446285046fcd426d90c18f37d2905
>>>>> # good: [a5b966ae42a70b194b03eaa5eaea70d8b3790c40] Merge branch 'tlb/a=
sm-generic' of git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux int=
o x86/mm
>>>>> git bisect good a5b966ae42a70b194b03eaa5eaea70d8b3790c40
>>>>> # first bad commit: [a31acd3ee8f7dbc0370bdf4a4bfef7a8c13c7542] x86/mm:=
 Page size aware flush_tlb_mm_range()
>>>>>=20
>>>>> And 'funnily' the bad patch is one of mine too :/
>>>>>=20
>>>>> I'll go have a look at that tomorrow, because currrently I'm way past
>>>>> tired.
>>>>=20
>>>> OK, so the below patchlet makes it all good. It turns out that the
>>>> provided config has:
>>>>=20
>>>> CONFIG_X86_L1_CACHE_SHIFT=3D7
>>>>=20
>>>> which then, for some obscure raisin, results in flush_tlb_mm_range()
>>>> compiling to use 320 bytes of stack:
>>>>=20
>>>> sub    $0x140,%rsp
>>>>=20
>>>> Where a 'defconfig' build results in:
>>>>=20
>>>> sub    $0x58,%rsp
>>>>=20
>>>> The thing that pushes it over the edge in the above fingered patch is
>>>> the addition of a field to struct flush_tlb_info, which grows if from 3=
2
>>>> to 36 bytes.
>>>>=20
>>>> So my proposal is to basically revert that, unless we can come up with
>>>> something that GCC can't screw up.
>>>=20
>>> To clarify, 'that' is Nadav's patch:
>>>=20
>>> 515ab7c41306 ("x86/mm: Align TLB invalidation info")
>>>=20
>>> which turns out to be the real problem.
>>=20
>> Sorry for that. I still think it should be aligned, especially with all t=
he
>> effort the Intel puts around to avoid bus-locking on unaligned atomic
>> operations.
>>=20
>> So the right solution seems to me as putting this data structure off stac=
k.
>> It would prevent flush_tlb_mm_range() from being reentrant, so we can kee=
p a
>> few entries for this matter and atomically increase the entry number ever=
y
>> time we enter flush_tlb_mm_range().
>>=20
>> But my question is - should flush_tlb_mm_range() be reentrant, or can we
>> assume no TLB shootdowns are initiated in interrupt handlers and #MC
>> handlers?
>=20
> Peter, what do you say about this one? I assume there are no nested TLB
> flushes, but the code can easily be adapted (assuming there is a limit on
> the nesting level).

You need IRQs on to flush, right?  So as long as preemption is off, it won=E2=
=80=99t nest.

But is there really any measurable performance benefit to aligning it like t=
his?  There shouldn=E2=80=99t actually be any atomically =E2=80=94 it=E2=80=99=
s just a little data structure telling everyone what to do.

>=20
> -- >8 --
>=20
> Subject: [PATCH] x86: Move flush_tlb_info off the stack
> ---
> arch/x86/mm/tlb.c | 49 +++++++++++++++++++++++++++++++++--------------
> 1 file changed, 35 insertions(+), 14 deletions(-)
>=20
> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> index bc4bc7b2f075..15fe90d4e3e1 100644
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -14,6 +14,7 @@
> #include <asm/cache.h>
> #include <asm/apic.h>
> #include <asm/uv/uv.h>
> +#include <asm/local.h>
>=20
> #include "mm_internal.h"
>=20
> @@ -722,43 +723,63 @@ void native_flush_tlb_others(const struct cpumask *c=
pumask,
>  */
> unsigned long tlb_single_page_flush_ceiling __read_mostly =3D 33;
>=20
> +static DEFINE_PER_CPU_SHARED_ALIGNED(struct flush_tlb_info, flush_tlb_inf=
o);
> +#ifdef CONFIG_DEBUG_VM
> +static DEFINE_PER_CPU(local_t, flush_tlb_info_idx);
> +#endif
> +
> void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
>                unsigned long end, unsigned int stride_shift,
>                bool freed_tables)
> {
> +    struct flush_tlb_info *info;
>    int cpu;
>=20
> -    struct flush_tlb_info info __aligned(SMP_CACHE_BYTES) =3D {
> -        .mm =3D mm,
> -        .stride_shift =3D stride_shift,
> -        .freed_tables =3D freed_tables,
> -    };
> -
>    cpu =3D get_cpu();
>=20
> +    info =3D this_cpu_ptr(&flush_tlb_info);
> +
> +#ifdef CONFIG_DEBUG_VM
> +    /*
> +     * Ensure that the following code is non-reentrant and flush_tlb_info=

> +     * is not overwritten. This means no TLB flushing is initiated by
> +     * interrupt handlers and machine-check exception handlers. If needed=
,
> +     * we can add additional flush_tlb_info entries.
> +     */
> +    BUG_ON(local_inc_return(this_cpu_ptr(&flush_tlb_info_idx)) !=3D 1);
> +#endif
> +
> +    info->mm =3D mm;
> +    info->stride_shift =3D stride_shift;
> +    info->freed_tables =3D freed_tables;
> +
>    /* This is also a barrier that synchronizes with switch_mm(). */
> -    info.new_tlb_gen =3D inc_mm_tlb_gen(mm);
> +    info->new_tlb_gen =3D inc_mm_tlb_gen(mm);
>=20
>    /* Should we flush just the requested range? */
>    if ((end !=3D TLB_FLUSH_ALL) &&
>        ((end - start) >> stride_shift) <=3D tlb_single_page_flush_ceiling)=
 {
> -        info.start =3D start;
> -        info.end =3D end;
> +        info->start =3D start;
> +        info->end =3D end;
>    } else {
> -        info.start =3D 0UL;
> -        info.end =3D TLB_FLUSH_ALL;
> +        info->start =3D 0UL;
> +        info->end =3D TLB_FLUSH_ALL;
>    }
>=20
>    if (mm =3D=3D this_cpu_read(cpu_tlbstate.loaded_mm)) {
> -        VM_WARN_ON(irqs_disabled());
> +        lockdep_assert_irqs_enabled();
>        local_irq_disable();
> -        flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
> +        flush_tlb_func_local(info, TLB_LOCAL_MM_SHOOTDOWN);
>        local_irq_enable();
>    }
>=20
>    if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
> -        flush_tlb_others(mm_cpumask(mm), &info);
> +        flush_tlb_others(mm_cpumask(mm), info);
>=20
> +#ifdef CONFIG_DEBUG_VM
> +    barrier();
> +    local_dec(this_cpu_ptr(&flush_tlb_info_idx));
> +#endif
>    put_cpu();
> }
>=20
> --=20
> 2.17.1
>=20
>=20

