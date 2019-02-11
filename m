Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED587C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:18:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A048222A2
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:18:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TvVF7Po4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A048222A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C2538E0142; Mon, 11 Feb 2019 14:18:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4487F8E0134; Mon, 11 Feb 2019 14:18:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E9E28E0142; Mon, 11 Feb 2019 14:18:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD0198E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:18:58 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id t72so1094pfi.21
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:18:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=U6QTzJmyKky3utGjaHrGeaTnG1UolmYGOzcU+sH5Y+4=;
        b=oKUem+AgdsWrHFx1KFo2u2JwDTmtzoZ2skGvBCK0i+EG1I6PHuVrTnXpAx2q+gOFpG
         NB8BAsOXb+Z2bf5GdfT4FxbC3JJa8cqrdAvYOgTJfvWvjjcfFHBUDqnbWZICuV3yo4JI
         s0Th+6d8PWWJto27OVXVuLKbADJsoeXzppyDw7WTg5TtQCBZypTewdz4f2SBhMRbKtya
         Ly2p3vyBH4ZPg4W/ENpWfmQUx0qP+ktZJeWWqAByvxHy5D8SyPaOEmCEzE+dpgWMK9k6
         YPkHqbqzmTkRJYYL+tt/2EgIXT82mKkKTlzWgDBRS7irPdZ00pCdNmGT8aCnIcsUTE2g
         4d4A==
X-Gm-Message-State: AHQUAuaBj4Kx9vpyJU45+2XoXipY6EeCT47rqyMnvPUH2G8Kv/kIz9fA
	kcwWkH5sTwWrl/oNjNgnK8H3nnfFpYweSpxWFRexFUlaeIK5y/L7xKINwGXo0sBOX+3LYfpccSv
	2/2Ju/G0XjVU91ZbzrtzG4ctB7x6iqBgw88gkT3SfkzASk5cGbYyrHi48qcbbxQAf7+9n6Spmec
	nElhn9riojeIxdIs53noBRu1ZFlGnhumUVyvcaBz9/tywMfrgoehMJuLO1HDDOhvEivuESwJ7yk
	D0BRYkmb/ofWxwqfRZoPdQExjULtZCxDG4DVbx5/3GK1jmnUiMgcoIlZaIUpgIUF/sim2dBBT29
	8JxT/5PMJAVQnSVBHugkLZBOEfO5JkpFrepj8sdZCaoHQb9hyFI+XaYEDIn4GeI186mylVFWM7a
	V
X-Received: by 2002:a65:608d:: with SMTP id t13mr35565329pgu.129.1549912738580;
        Mon, 11 Feb 2019 11:18:58 -0800 (PST)
X-Received: by 2002:a65:608d:: with SMTP id t13mr35565281pgu.129.1549912737845;
        Mon, 11 Feb 2019 11:18:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549912737; cv=none;
        d=google.com; s=arc-20160816;
        b=idYxCKG33SmPaewbXwD4vmYvrB2s0o4Cn6PxPiILTOtC8ZehghV4N0Ah9M2GICUjcA
         GxdWhLgD0/EKMH4QPjm0U0b0Kr+fgwI2R/Qq1JAOuLMUBFluu/Fw7cFQMxDwU6E4ksKr
         vJyjV2N3AELIAPmO8I8DRJLrOHnaLQoFkXwXgUhlBDR+CdY43HAtr1DVoer3Zn/AnGcq
         vr9xEFz+hzfPX4vNGQk+z7JQY3DoKO8RA7iSi8wiFBUIdlMB15WFdPLgiXbp8prQr7R+
         8+dVk55kh0/Pq8teTWw8UAWRHFF5FgPOXh9wksvoJs3uzllAD1ZsMmPlpp5+Bk9ziqI+
         o2dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=U6QTzJmyKky3utGjaHrGeaTnG1UolmYGOzcU+sH5Y+4=;
        b=ZGyqib7Ul/Vf2p+Gq6vXnxqD0+/Sw2pOoYmUL/mZKY7g34o7zp363FeY4V6VQKfJIf
         4+v3y6yng+4O3ahWgak0wlXSHOn50LGXW5tx310/pAN1vWaG1rG6yo87YJlR5u2b0KMV
         lQ/TJaaD0dTvTejxcsUoKFmgvjSAiqMoZ/N6RyIAZQ+IWs6cF9vsz6d9mWxJ7TeDRc6s
         bjil2zQzOVCLLDF+B40O0oWPr5EMwmARk+npBn8rvg4R0/uGaHkq6drNE5oINap0OWVe
         f170xM5voeQuOGXMX8BfG4JRKXD1TMz7TZFkpkFig0lHo4GrTLVArUsYkF3riZ5W5naG
         JdgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TvVF7Po4;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g3sor15718175plp.57.2019.02.11.11.18.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 11:18:57 -0800 (PST)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TvVF7Po4;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=U6QTzJmyKky3utGjaHrGeaTnG1UolmYGOzcU+sH5Y+4=;
        b=TvVF7Po4LRk8+UgMyGoXm30CgOd2P6lLmVQn5RZpI5wUzIIoXXtfNAIuqOawTWBGPz
         fS8pjD5cnntQXdELvDLrmIhIFRbp16FQ9xPi/oZa9wRP2NsSsk0ZeyiZlhdJ7Q6TWS9p
         B/lWPUJG7L51x8P3v11HCJuoAlMo5Cxh6bqt53b7xu5PEh2sbNjmF4hY8sZSsijX50TG
         z9qwZ9yHnDkkM/UvCy1vFaOs16f61CnxVKCy2cLC/H939Gke2R+uKpDmLiFm/rkL5Wmt
         ULnZbBqh7G3JPu66P9osymbRJoRcdI/lfk173jGzpMMFkFolagtGay4aT+8Gc3jvSfLT
         izzA==
X-Google-Smtp-Source: AHgI3IanC/OTNWPI8Kzdg7h23REmR+aXWc9nczhB8ikk5z0mmrBH5R/gEZhhv/eMlxu6ih5oZqdkJQ==
X-Received: by 2002:a17:902:32c3:: with SMTP id z61mr38926435plb.114.1549912737334;
        Mon, 11 Feb 2019 11:18:57 -0800 (PST)
Received: from [10.33.115.182] ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id z7sm14168103pga.6.2019.02.11.11.18.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:18:56 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2 05/20] x86/alternative: initializing temporary mm for
 patching
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <CALCETrVaBaorbOA8QE=Pk=C+PfXZAz0-aX_3O8Y=nJV4QKELbw@mail.gmail.com>
Date: Mon, 11 Feb 2019 11:18:54 -0800
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>,
 Ingo Molnar <mingo@redhat.com>,
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
Message-Id: <3EA322C6-5645-4900-AEC6-97FC05716F75@gmail.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-6-rick.p.edgecombe@intel.com>
 <162C6C29-CD81-46FE-9A54-6ED05A93A9CB@gmail.com>
 <00649AE8-69C0-4CD2-A916-B8C8F0F5DAC3@amacapital.net>
 <6FE10C97-25FF-4E99-A96A-465CBACA935B@gmail.com>
 <CALCETrVaBaorbOA8QE=Pk=C+PfXZAz0-aX_3O8Y=nJV4QKELbw@mail.gmail.com>
To: Andy Lutomirski <luto@kernel.org>
X-Mailer: Apple Mail (2.3445.102.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Feb 11, 2019, at 11:07 AM, Andy Lutomirski <luto@kernel.org> wrote:
>=20
> I'm certainly amenable to other solutions, but this one does seem the
> least messy.  I looked at my old patch, and it doesn't do what you
> want.  I'd suggest you just add a percpu variable like cpu_dr7 and rig
> up some accessors so that it stays up to date.  Then you can skip the
> dr7 writes if there are no watchpoints set.
>=20
> Also, EFI is probably a less interesting example than rare_write.
> With rare_write, especially the dynamically allocated variants that
> people keep coming up with, we'll need a swath of address space fully
> as large as the vmalloc area. and getting *that* right while still
> using the kernel address range might be more of a mess than we really
> want to deal with.

As long as you feel comfortable with this solution, I=E2=80=99m fine =
with it.

Here is what I have (untested). I prefer to save/restore all the DRs,
because IIRC DR6 indications are updated even if breakpoints are =
disabled
(in DR7). And anyhow, that is the standard interface.


-- >8 --

From: Nadav Amit <namit@vmware.com>
Date: Mon, 11 Feb 2019 03:07:08 -0800
Subject: [PATCH] mm: save DRs when loading temporary mm

Signed-off-by: Nadav Amit <namit@vmware.com>
---
 arch/x86/include/asm/mmu_context.h | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/arch/x86/include/asm/mmu_context.h =
b/arch/x86/include/asm/mmu_context.h
index d684b954f3c0..4f92ec3df149 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -13,6 +13,7 @@
 #include <asm/tlbflush.h>
 #include <asm/paravirt.h>
 #include <asm/mpx.h>
+#include <asm/debugreg.h>
=20
 extern atomic64_t last_mm_ctx_id;
=20
@@ -358,6 +359,7 @@ static inline unsigned long =
__get_current_cr3_fast(void)
=20
 typedef struct {
 	struct mm_struct *prev;
+	unsigned short bp_enabled : 1;
 } temp_mm_state_t;
=20
 /*
@@ -380,6 +382,15 @@ static inline temp_mm_state_t =
use_temporary_mm(struct mm_struct *mm)
 	lockdep_assert_irqs_disabled();
 	state.prev =3D this_cpu_read(cpu_tlbstate.loaded_mm);
 	switch_mm_irqs_off(NULL, mm, current);
+
+	/*
+	 * If breakpoints are enabled, disable them while the temporary =
mm is
+	 * used - they do not belong and might cause wrong signals or =
crashes.
+	 */
+	state.bp_enabled =3D hw_breakpoint_active();
+	if (state.bp_enabled)
+		hw_breakpoint_disable();
+
 	return state;
 }
=20
@@ -387,6 +398,13 @@ static inline void =
unuse_temporary_mm(temp_mm_state_t prev)
 {
 	lockdep_assert_irqs_disabled();
 	switch_mm_irqs_off(NULL, prev.prev, current);
+
+	/*
+	 * Restore the breakpoints if they were disabled before the =
temporary mm
+	 * was loaded.
+	 */
+	if (prev.bp_enabled)
+		hw_breakpoint_restore();
 }
=20
 #endif /* _ASM_X86_MMU_CONTEXT_H */
--=20
2.17.1


