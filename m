Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E30BC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 05:18:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06DE620855
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 05:18:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="xyuciNjk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06DE620855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70D6C8E00BF; Mon, 11 Feb 2019 00:18:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E3F08E00BE; Mon, 11 Feb 2019 00:18:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FB858E00BF; Mon, 11 Feb 2019 00:18:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1EFCD8E00BE
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 00:18:40 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 71so8516804plf.19
        for <linux-mm@kvack.org>; Sun, 10 Feb 2019 21:18:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=P/nz3ACoxpLDqb0eHS2Lbfh7g08M62jcwE0fE5p6slQ=;
        b=bWfgFR1vSBobSRaQYbAxNy7oXes18C3UfMWSbNG+H+8OvRUeXbUMLILBEsyht8TMO/
         c1ZM/IWIdLB6ms3kB02ecJdZhUdG3V7Fj3OjS11D/q42ETje/8R7XsXQZDdZlQhK8d6I
         pPV4rjKjmr2KADIi8moZvhPvsIMlKKhAcbt5K5YAuVzOshJLx/gTGXVQvJ+uTgaWebGa
         oN7oNUA+LwLb+UyUk8mdDaD3LfIn69XyjMhgByKK3A6KfJEcZc+d7UmTlNCJnhJV4yqk
         +Y3DRPubtEQDwhJvnIYTc7LzOFyjZZPRWLOUXgcCTiSPCp+LVK4zvCDrTRT1pOGR5r5M
         XC+A==
X-Gm-Message-State: AHQUAuZtoLzKuLUuJCNt+DNYlTpYwdJmJQtBPnVCqvVCBsAf8sAg7S5n
	11wOva6LLBBu3OLqjMlyd8mC/FvEtw+KF6hKG4FtsMSqe4FBUvKNKQCM4zpz/zKZYkukkVRpJ/Y
	6aqGR849yr1RYWwMXKOtBKK3cy3Y65w/gw9LZUwpT/PeNiX2fpsTfnFvYsPb4r+BKBNZo+HTucy
	WjgiZvGRXTPuox2/q3R9JNlV7OY6tpkom0QMSmzTOkkKgtqpaOrtmXZ4wGKVuMr+eAVXo5V5HPo
	NmLt43LlunUcoxgMURgrhSDgcy7y9SS8DIyCjStqcS4Ng394DFk9Dfr1gwPTniBFULF5RX6y0y8
	dNigoW1GCD8HJvx+51lqGmqbOB42io4R8WfYyEnH1r8x5990oNmHohuLHBu/kldS4n5i2WPPS7v
	E
X-Received: by 2002:a17:902:b114:: with SMTP id q20mr31373218plr.48.1549862319724;
        Sun, 10 Feb 2019 21:18:39 -0800 (PST)
X-Received: by 2002:a17:902:b114:: with SMTP id q20mr31373126plr.48.1549862318053;
        Sun, 10 Feb 2019 21:18:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549862318; cv=none;
        d=google.com; s=arc-20160816;
        b=hnbttlZ7EOEu+oqXbj7/uA8WDrB/H7IQjVrgnPxyD83VPMlNHpNfoWYAlEMciRGJ/M
         4HYd4UKNEudKVON4+5YHcUUC/oiYtpS4ohDb0MfGfXDNKmsYsvP8TTJPhExiMPMrwC5f
         zaYGzLTaCjMIFRpD6oDJaDywdNk8imG02T6kiFGNflWGsmzkFcv9x79Qw0rfIpUXT3So
         qwWgw7HfsTARV8tr9SBoEd/3cxdizqHO5gz1yfcN0PiR4C9qpJtaWCKNL3b4uml1KB6p
         Nvi0pjkdvfLIpzMy62vtmYqiCWhjxqPwJEPSkye2G1gGAoHZL+byxE4ltxAZTafyTA5W
         BVKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=P/nz3ACoxpLDqb0eHS2Lbfh7g08M62jcwE0fE5p6slQ=;
        b=l9/bxizOYIudyLDDBTm5RylBNs/rcDp0edq4S1w0MPbcKiz4gEWsQ3evyedGqLJB5q
         ddvvx65lDT7NyRNKGIBN+UIxaz7J9wmLdVHO4uKh7t0zmq5mDZPL1MFQpELj06o42WFY
         lQCZ1P8w05RVi7ov8Xtp+tr7UgRL5q02Y5BFLJKFAlkyexaZmBG8SHBydzcX/QyHbr7R
         2cTSQneI26+PvF7BdiojOsrjcmQQ3JoMBZtHASaeYHhbsODbRfvlM5Qu0BHlFabZIzQj
         OQPLUm0wMah4k6ucKYbpPkOKe2MystGnF+PgTml0F5SDnMeg12G/QcBqGAu5eRW4Hr0B
         DNHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=xyuciNjk;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor12241339pgp.31.2019.02.10.21.18.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Feb 2019 21:18:38 -0800 (PST)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=xyuciNjk;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=P/nz3ACoxpLDqb0eHS2Lbfh7g08M62jcwE0fE5p6slQ=;
        b=xyuciNjkFWciBsSx/is2lBM2iiUNDec2HmbyGj9VTUJYEYAUDuSAr19G2O+5RQXZja
         kDN98a6hx1onWzTw7CzmW+8qMZmYMnWAibmq/6o1dY+qqCj/M3v6KtlTjBFVdVkmnHU7
         0aadpz2eqQLSu6Ist19NGgHJ/rqUS0wyDRkHsl/XcQorAL9QaroZvLPCNGCdzSNG0/sD
         jkdB1uk7FF3ixo/nUGKC57zIIWHDq+mUzpn29lf3AgAXtDae1qKETi1id1Y4c6r3ZFRG
         fr2FI8bBDK7khVD+ie9FEuGxSE6QU26XGV9pCOiVMG3MKav8TqVqSrNRJ0uvlV/Q4j8B
         o21Q==
X-Google-Smtp-Source: AHgI3IZOahjUxu+t0qhpsn/mwzusbGjfiQw5XyvsSy/I2w+d8AyD7+Aa4/VTebWQOBBX1/tTqaH/jA==
X-Received: by 2002:a63:61d8:: with SMTP id v207mr7347489pgb.308.1549862317394;
        Sun, 10 Feb 2019 21:18:37 -0800 (PST)
Received: from ?IPv6:2601:646:c200:7429:5d4d:83bf:b51b:8718? ([2601:646:c200:7429:5d4d:83bf:b51b:8718])
        by smtp.gmail.com with ESMTPSA id l11sm11539621pff.65.2019.02.10.21.18.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Feb 2019 21:18:35 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v2 05/20] x86/alternative: initializing temporary mm for patching
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16C101)
In-Reply-To: <162C6C29-CD81-46FE-9A54-6ED05A93A9CB@gmail.com>
Date: Sun, 10 Feb 2019 21:18:34 -0800
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>,
 Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>,
 "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>,
 Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Damian Tometzki <linux_dti@icloud.com>,
 linux-integrity <linux-integrity@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux-MM <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Kristen Carlson Accardi <kristen@linux.intel.com>,
 "Dock, Deneen T" <deneen.t.dock@intel.com>,
 Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <00649AE8-69C0-4CD2-A916-B8C8F0F5DAC3@amacapital.net>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com> <20190129003422.9328-6-rick.p.edgecombe@intel.com> <162C6C29-CD81-46FE-9A54-6ED05A93A9CB@gmail.com>
To: Nadav Amit <nadav.amit@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On Feb 10, 2019, at 4:39 PM, Nadav Amit <nadav.amit@gmail.com> wrote:

>> On Jan 28, 2019, at 4:34 PM, Rick Edgecombe <rick.p.edgecombe@intel.com> w=
rote:
>>=20
>> From: Nadav Amit <namit@vmware.com>
>>=20
>> To prevent improper use of the PTEs that are used for text patching, we
>> want to use a temporary mm struct. We initailize it by copying the init
>> mm.
>>=20
>> The address that will be used for patching is taken from the lower area
>> that is usually used for the task memory. Doing so prevents the need to
>> frequently synchronize the temporary-mm (e.g., when BPF programs are
>> installed), since different PGDs are used for the task memory.
>>=20
>> Finally, we randomize the address of the PTEs to harden against exploits
>> that use these PTEs.
>>=20
>> Cc: Kees Cook <keescook@chromium.org>
>> Cc: Dave Hansen <dave.hansen@intel.com>
>> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
>> Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
>> Tested-by: Masami Hiramatsu <mhiramat@kernel.org>
>> Suggested-by: Andy Lutomirski <luto@kernel.org>
>> Signed-off-by: Nadav Amit <namit@vmware.com>
>> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
>> ---
>> arch/x86/include/asm/pgtable.h       |  3 +++
>> arch/x86/include/asm/text-patching.h |  2 ++
>> arch/x86/kernel/alternative.c        |  3 +++
>> arch/x86/mm/init_64.c                | 36 ++++++++++++++++++++++++++++
>> init/main.c                          |  3 +++
>> 5 files changed, 47 insertions(+)
>>=20
>> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtabl=
e.h
>> index 40616e805292..e8f630d9a2ed 100644
>> --- a/arch/x86/include/asm/pgtable.h
>> +++ b/arch/x86/include/asm/pgtable.h
>> @@ -1021,6 +1021,9 @@ static inline void __meminit init_trampoline_defaul=
t(void)
>>    /* Default trampoline pgd value */
>>    trampoline_pgd_entry =3D init_top_pgt[pgd_index(__PAGE_OFFSET)];
>> }
>> +
>> +void __init poking_init(void);
>> +
>> # ifdef CONFIG_RANDOMIZE_MEMORY
>> void __meminit init_trampoline(void);
>> # else
>> diff --git a/arch/x86/include/asm/text-patching.h b/arch/x86/include/asm/=
text-patching.h
>> index f8fc8e86cf01..a75eed841eed 100644
>> --- a/arch/x86/include/asm/text-patching.h
>> +++ b/arch/x86/include/asm/text-patching.h
>> @@ -39,5 +39,7 @@ extern void *text_poke_kgdb(void *addr, const void *opc=
ode, size_t len);
>> extern int poke_int3_handler(struct pt_regs *regs);
>> extern void *text_poke_bp(void *addr, const void *opcode, size_t len, voi=
d *handler);
>> extern int after_bootmem;
>> +extern __ro_after_init struct mm_struct *poking_mm;
>> +extern __ro_after_init unsigned long poking_addr;
>>=20
>> #endif /* _ASM_X86_TEXT_PATCHING_H */
>> diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.=
c
>> index 12fddbc8c55b..ae05fbb50171 100644
>> --- a/arch/x86/kernel/alternative.c
>> +++ b/arch/x86/kernel/alternative.c
>> @@ -678,6 +678,9 @@ void *__init_or_module text_poke_early(void *addr, co=
nst void *opcode,
>>    return addr;
>> }
>>=20
>> +__ro_after_init struct mm_struct *poking_mm;
>> +__ro_after_init unsigned long poking_addr;
>> +
>> static void *__text_poke(void *addr, const void *opcode, size_t len)
>> {
>>    unsigned long flags;
>> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
>> index bccff68e3267..125c8c48aa24 100644
>> --- a/arch/x86/mm/init_64.c
>> +++ b/arch/x86/mm/init_64.c
>> @@ -53,6 +53,7 @@
>> #include <asm/init.h>
>> #include <asm/uv/uv.h>
>> #include <asm/setup.h>
>> +#include <asm/text-patching.h>
>>=20
>> #include "mm_internal.h"
>>=20
>> @@ -1383,6 +1384,41 @@ unsigned long memory_block_size_bytes(void)
>>    return memory_block_size_probed;
>> }
>>=20
>> +/*
>> + * Initialize an mm_struct to be used during poking and a pointer to be u=
sed
>> + * during patching.
>> + */
>> +void __init poking_init(void)
>> +{
>> +    spinlock_t *ptl;
>> +    pte_t *ptep;
>> +
>> +    poking_mm =3D copy_init_mm();
>> +    BUG_ON(!poking_mm);
>> +
>> +    /*
>> +     * Randomize the poking address, but make sure that the following pa=
ge
>> +     * will be mapped at the same PMD. We need 2 pages, so find space fo=
r 3,
>> +     * and adjust the address if the PMD ends after the first one.
>> +     */
>> +    poking_addr =3D TASK_UNMAPPED_BASE;
>> +    if (IS_ENABLED(CONFIG_RANDOMIZE_BASE))
>> +        poking_addr +=3D (kaslr_get_random_long("Poking") & PAGE_MASK) %=

>> +            (TASK_SIZE - TASK_UNMAPPED_BASE - 3 * PAGE_SIZE);
>> +
>> +    if (((poking_addr + PAGE_SIZE) & ~PMD_MASK) =3D=3D 0)
>> +        poking_addr +=3D PAGE_SIZE;
>=20
> Further thinking about it, I think that allocating the virtual address for=

> poking from user address-range is problematic. The user can set watchpoint=
s
> on different addresses, cause some static-keys to be enabled/disabled, and=

> monitor the signals to derandomize the poking address.
>=20

Hmm, I hadn=E2=80=99t thought about watchpoints. I=E2=80=99m not sure how mu=
ch we care about possible derandomization like this, but we certainly don=E2=
=80=99t want to send signals or otherwise malfunction.

> Andy, I think you were pushing this change. Can I go back to use a vmalloc=
=E2=80=99d
> address instead, or do you have a better solution?

Hmm. If we use a vmalloc address, we have to make sure it=E2=80=99s not actu=
ally allocated. I suppose we could allocate one once at boot and use that.  W=
e also have the problem that the usual APIs for handling =E2=80=9Cuser=E2=80=
=9D addresses might assume they=E2=80=99re actually in the user range, altho=
ugh this seems unlikely to be a problem in practice.  More seriously, though=
, the code that manipulates per-mm paging structures assumes that *all* of t=
he structures up to the top level are per-mm, and, if we use anything less t=
han a private pgd, this isn=E2=80=99t the case.

> I prefer not to
> save/restore DR7, of course.
>=20

I suspect we may want to use the temporary mm concept for EFI, too, so we ma=
y want to just suck it up and save/restore DR7.  But only if a watchpoint is=
 in use, of course. I have an old patch I could dust off that tracks DR7 to m=
ake things like this efficient.=

