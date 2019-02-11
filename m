Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98375C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 00:39:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D18A2083B
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 00:39:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UQvVKtfi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D18A2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76B368E00C0; Sun, 10 Feb 2019 19:39:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 719598E00BF; Sun, 10 Feb 2019 19:39:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 608CB8E00C0; Sun, 10 Feb 2019 19:39:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2133D8E00BF
	for <linux-mm@kvack.org>; Sun, 10 Feb 2019 19:39:26 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id v82so3520563pfj.9
        for <linux-mm@kvack.org>; Sun, 10 Feb 2019 16:39:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=vlsxxAOCWdf1tlqbQayeYqdEQq3U0CPDi/Q8SjZG81o=;
        b=G8NkclQHvIbc8emQ5oSxMuEkCy1Lz5h3pCn1NPgpZe0O0i+rRiYyOaRHvb1Iqr5mtR
         t6yHytgr4RGHxkuDBapFfD4dMAqtTfG0ZwyMUogDF7URP9Ezg6DGAOHTLbZIFYF7IuF2
         aDcdJLzSQo6Dd4hNIos9BJDgRvItR+baYv3uA+4MGno/nGw5E0IY4MBS1UX6DCRoFNSR
         kpxYdEOLykgYS5xp+y7D0JQbTeOO7wBKt3lZvBFXX4mJGw7Jdja4nPyV4g3TpB8rMivw
         9YqbI0C/cDjCzEppEI1ncM+YNjOXXZ1mgh7/JWHTIhn8Ikn+4MqL+9azKKkqihH0dnzg
         Ezsw==
X-Gm-Message-State: AHQUAubzpwf2RAL2RTi3lzzv4kdDz3xlLVkSJn34QE66v2pX18KIhIuP
	5sdoS43wekDwQ0D8DEKc/eSJtoMdxy7cWcwHVmuBuftDOODCTnYpv6gUI/goSBYkyO4AbiK0anE
	MQsa3EZFlcvbubB6mt1nJWIP/lUBOhxPgY8bbaJn9VPmxO1H6ozvdO38jBxtdhRJsCsAHSsxAbN
	LyMViKq+unwxTb7c4SblmdHAWRHe4YVAfmPXX091ReSvMC+xxj/FIqnbIOOjbYMz5RW7rMx48tW
	D/XQNrnWqGL+H871aki+vRjmdkfArcE7dzo0xsEz6Zdyeloz9XTbLgtzNmf0rpiRdtVb9D0sbfL
	TFM1RIsQwOpX1V6mkBqS3veDj+RNl+L7SVPLbvpk4m0NENB5OzJh76mC6xVIK8UtV+glER77IR8
	w
X-Received: by 2002:a17:902:8303:: with SMTP id bd3mr27329019plb.10.1549845565578;
        Sun, 10 Feb 2019 16:39:25 -0800 (PST)
X-Received: by 2002:a17:902:8303:: with SMTP id bd3mr27328992plb.10.1549845564730;
        Sun, 10 Feb 2019 16:39:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549845564; cv=none;
        d=google.com; s=arc-20160816;
        b=D5sEBxnb5XvafH6G0U27XZVDoa4PMSpRY+GjRCNa2GtylxPiDvoHmze/EQD8KuW1Bi
         4puyBCEJ4veTefLdbrc5Fz6S8ErxBW06LapFkw5yld7lO+MAN0DzWKNDtI5yydalzfn1
         wKvCB/3ASYJxmt2qMCiCqVkkuss6V5ZRD6y26XkDTo5TY2DhVdoBDrKvGVz8w9/u3wiV
         KVB2jhtxndQfRSex2KJ2iOcOx9V53PTIpzukXA1NC360H/P5HA/UAWyOYHldeQd8M4uZ
         fk64tOO5B3udDRZFAebFiGFFf11fM+W4elZBSgDxWJOdnGJMgxTuGy54AH7v7tUQGGXA
         o9kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=vlsxxAOCWdf1tlqbQayeYqdEQq3U0CPDi/Q8SjZG81o=;
        b=JauBEIURavuu6/25MQB2wRFnBvhIwD6Xs19yjk3Mj3eY5EZ77HIHZ4f6yreFdc3QPP
         xppNmxOCDptPIHQ+vjynXyJWOT/kYmNIdll5/qK45pKqlFKsWC0PE7NLwqZV8yjUuuuw
         m4boRGruDzW8L7kqrFKiublNxYMjMLvzCr5/4z3waI/SFGJnsnWPWPxcto+rPEPNemLB
         DUlbgatUycl34zQh5znUjgcAcVcDDap5U3DSZvTLk/IXKEJVRwcEx5mI9zoCi7xC3AtQ
         KgRNUvspEv1rqouUARjlCJAnoQYtWfP9blldRRL3hKZ8r7PVgNnc7QR5Mn9qkFF74WSO
         Nlow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UQvVKtfi;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d10sor11811147pgp.21.2019.02.10.16.39.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Feb 2019 16:39:24 -0800 (PST)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UQvVKtfi;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=vlsxxAOCWdf1tlqbQayeYqdEQq3U0CPDi/Q8SjZG81o=;
        b=UQvVKtfiCr2EL7+vDHwobTr3K/ATiEL/6IaQ02QiiMOUdtOTSwVzMksz6CS8ZV0yRJ
         +ba/xxOchi8VyXAnM7fVo60oRNFj2udtb1MmjepZeHgrxDVhybrDVbj5WnMxeBHOoSbd
         0Z4ougOyd3gTbL/2dtgAdkuVZoPi7UgLUoLhCdvNzCWYP7JyWQGoErFnT2bIT8jpwJmW
         nl39hGFURBJeHi1zjBdzVmWXygssw8dBEZN8YX3pDj+23Sy5XTbd9Z4jeitLC9T6yCR+
         E1iLowwEvYjOZ49Ev4OpC1K+CVW6/aZvC6taNcnStgVkXC3RxCvWyjQ73aHhhLIXT7n4
         svbw==
X-Google-Smtp-Source: AHgI3Ia6ifDLiDziehHa+LGRKtMr/aFcCrLoukw/oRH9ekCRaSYyb/4JRm26BQzyIcR0N6IRbjlQYw==
X-Received: by 2002:a63:5d20:: with SMTP id r32mr15872762pgb.329.1549845563697;
        Sun, 10 Feb 2019 16:39:23 -0800 (PST)
Received: from [10.50.121.96] (c-73-202-78-81.hsd1.ca.comcast.net. [73.202.78.81])
        by smtp.gmail.com with ESMTPSA id x2sm13973798pfx.78.2019.02.10.16.39.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Feb 2019 16:39:22 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2 05/20] x86/alternative: initializing temporary mm for
 patching
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20190129003422.9328-6-rick.p.edgecombe@intel.com>
Date: Sun, 10 Feb 2019 16:39:19 -0800
Cc: Ingo Molnar <mingo@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>,
 X86 ML <x86@kernel.org>,
 "H. Peter Anvin" <hpa@zytor.com>,
 Thomas Gleixner <tglx@linutronix.de>,
 Borislav Petkov <bp@alien8.de>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Damian Tometzki <linux_dti@icloud.com>,
 linux-integrity <linux-integrity@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux-MM <linux-mm@kvack.org>,
 Will Deacon <will.deacon@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Kristen Carlson Accardi <kristen@linux.intel.com>,
 "Dock, Deneen T" <deneen.t.dock@intel.com>,
 Kees Cook <keescook@chromium.org>,
 Dave Hansen <dave.hansen@intel.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <162C6C29-CD81-46FE-9A54-6ED05A93A9CB@gmail.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-6-rick.p.edgecombe@intel.com>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>,
 Andy Lutomirski <luto@kernel.org>
X-Mailer: Apple Mail (2.3445.102.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Jan 28, 2019, at 4:34 PM, Rick Edgecombe =
<rick.p.edgecombe@intel.com> wrote:
>=20
> From: Nadav Amit <namit@vmware.com>
>=20
> To prevent improper use of the PTEs that are used for text patching, =
we
> want to use a temporary mm struct. We initailize it by copying the =
init
> mm.
>=20
> The address that will be used for patching is taken from the lower =
area
> that is usually used for the task memory. Doing so prevents the need =
to
> frequently synchronize the temporary-mm (e.g., when BPF programs are
> installed), since different PGDs are used for the task memory.
>=20
> Finally, we randomize the address of the PTEs to harden against =
exploits
> that use these PTEs.
>=20
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
> Tested-by: Masami Hiramatsu <mhiramat@kernel.org>
> Suggested-by: Andy Lutomirski <luto@kernel.org>
> Signed-off-by: Nadav Amit <namit@vmware.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
> arch/x86/include/asm/pgtable.h       |  3 +++
> arch/x86/include/asm/text-patching.h |  2 ++
> arch/x86/kernel/alternative.c        |  3 +++
> arch/x86/mm/init_64.c                | 36 ++++++++++++++++++++++++++++
> init/main.c                          |  3 +++
> 5 files changed, 47 insertions(+)
>=20
> diff --git a/arch/x86/include/asm/pgtable.h =
b/arch/x86/include/asm/pgtable.h
> index 40616e805292..e8f630d9a2ed 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -1021,6 +1021,9 @@ static inline void __meminit =
init_trampoline_default(void)
> 	/* Default trampoline pgd value */
> 	trampoline_pgd_entry =3D init_top_pgt[pgd_index(__PAGE_OFFSET)];
> }
> +
> +void __init poking_init(void);
> +
> # ifdef CONFIG_RANDOMIZE_MEMORY
> void __meminit init_trampoline(void);
> # else
> diff --git a/arch/x86/include/asm/text-patching.h =
b/arch/x86/include/asm/text-patching.h
> index f8fc8e86cf01..a75eed841eed 100644
> --- a/arch/x86/include/asm/text-patching.h
> +++ b/arch/x86/include/asm/text-patching.h
> @@ -39,5 +39,7 @@ extern void *text_poke_kgdb(void *addr, const void =
*opcode, size_t len);
> extern int poke_int3_handler(struct pt_regs *regs);
> extern void *text_poke_bp(void *addr, const void *opcode, size_t len, =
void *handler);
> extern int after_bootmem;
> +extern __ro_after_init struct mm_struct *poking_mm;
> +extern __ro_after_init unsigned long poking_addr;
>=20
> #endif /* _ASM_X86_TEXT_PATCHING_H */
> diff --git a/arch/x86/kernel/alternative.c =
b/arch/x86/kernel/alternative.c
> index 12fddbc8c55b..ae05fbb50171 100644
> --- a/arch/x86/kernel/alternative.c
> +++ b/arch/x86/kernel/alternative.c
> @@ -678,6 +678,9 @@ void *__init_or_module text_poke_early(void *addr, =
const void *opcode,
> 	return addr;
> }
>=20
> +__ro_after_init struct mm_struct *poking_mm;
> +__ro_after_init unsigned long poking_addr;
> +
> static void *__text_poke(void *addr, const void *opcode, size_t len)
> {
> 	unsigned long flags;
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index bccff68e3267..125c8c48aa24 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -53,6 +53,7 @@
> #include <asm/init.h>
> #include <asm/uv/uv.h>
> #include <asm/setup.h>
> +#include <asm/text-patching.h>
>=20
> #include "mm_internal.h"
>=20
> @@ -1383,6 +1384,41 @@ unsigned long memory_block_size_bytes(void)
> 	return memory_block_size_probed;
> }
>=20
> +/*
> + * Initialize an mm_struct to be used during poking and a pointer to =
be used
> + * during patching.
> + */
> +void __init poking_init(void)
> +{
> +	spinlock_t *ptl;
> +	pte_t *ptep;
> +
> +	poking_mm =3D copy_init_mm();
> +	BUG_ON(!poking_mm);
> +
> +	/*
> +	 * Randomize the poking address, but make sure that the =
following page
> +	 * will be mapped at the same PMD. We need 2 pages, so find =
space for 3,
> +	 * and adjust the address if the PMD ends after the first one.
> +	 */
> +	poking_addr =3D TASK_UNMAPPED_BASE;
> +	if (IS_ENABLED(CONFIG_RANDOMIZE_BASE))
> +		poking_addr +=3D (kaslr_get_random_long("Poking") & =
PAGE_MASK) %
> +			(TASK_SIZE - TASK_UNMAPPED_BASE - 3 * =
PAGE_SIZE);
> +
> +	if (((poking_addr + PAGE_SIZE) & ~PMD_MASK) =3D=3D 0)
> +		poking_addr +=3D PAGE_SIZE;

Further thinking about it, I think that allocating the virtual address =
for
poking from user address-range is problematic. The user can set =
watchpoints
on different addresses, cause some static-keys to be enabled/disabled, =
and
monitor the signals to derandomize the poking address.

Andy, I think you were pushing this change. Can I go back to use a =
vmalloc=E2=80=99d
address instead, or do you have a better solution? I prefer not to
save/restore DR7, of course.

