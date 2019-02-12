Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FE74C282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:23:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4233F222C5
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:23:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PwWWi/6z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4233F222C5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C49178E0003; Tue, 12 Feb 2019 13:23:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF7D18E0001; Tue, 12 Feb 2019 13:23:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE7C58E0003; Tue, 12 Feb 2019 13:23:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1E98E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:23:39 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id l9so2795039plt.7
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:23:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=nxsq3mYQfT8TSMKFYDwSPeWmp3gy8uwIjz9pCZKxPZU=;
        b=rKhnwslq9zhzzgoYbKiT9OLtkEI65RlpmP0+elD56ZmCN0CMpmSf2wNH3SPxagN1KZ
         ISBzJx/vohw7xf7VkBjddJeSvrMjiTNGTDNgWKpKj36qtv5zstvWK8wpzY+Asr0J1FEr
         qAa8nDP+xqZ86nRBPUB2u1JdBaO4EBO2Y5RPtEgFAiBq2jLcTxO+telgtTBIjY9SaaX3
         sErcKCVys4Lz6IyZexKDp1/yIhLk0T/e5iC5fxN3JQgjqmF6RfwofigVEWKZKILBYsGf
         zF3QZ3M9nKbl9pO/L/dAKhrdtuM9g0XcHwgcCAWqjrzPBpEwEXRmS+9FFsvSjEkB2ly+
         OIXQ==
X-Gm-Message-State: AHQUAuYH65B3R6nzaBTBg6lcYiTN9c01Z1IoEqLxXSbUZk4s87JK0+Ei
	RWv+l4xIDcLv7KO8OPkN5cDoafKCLZQkB//6rTqHwi5O5jt4oDAvb30ToGwhwmuTnaS+QMu4BUb
	7524V7NpyaRxwkcIluQAVVdmUoupAk8DoYY4kZYZkuGabMms0/ec1Gj2HL0x4qyiLGsdStGu09A
	BIlRjAJyBVVB1fJvsw0AXJpZo+lFFjFZZPGK8vg4LdeCOyol9mOFWLw0QQNplVcOyVxLWi82OBC
	Zauej4NAUZYcqK4JHLIksGIoQNGoNfbCa5eTlX58UmqXYBaAC9jc4niBEu/7KkYA/tx/CZxZ75I
	klYxp7nRlt19BTwxhAQ/gVOq1tLrHWvkOaAOia5yTogGrvViLZ2XIM5tE7McYcPQYmYII8ZrPJV
	E
X-Received: by 2002:a65:4904:: with SMTP id p4mr4819057pgs.384.1549995819116;
        Tue, 12 Feb 2019 10:23:39 -0800 (PST)
X-Received: by 2002:a65:4904:: with SMTP id p4mr4819004pgs.384.1549995818309;
        Tue, 12 Feb 2019 10:23:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549995818; cv=none;
        d=google.com; s=arc-20160816;
        b=NfDRJ8gVsELDwA0BFEufiezTuzmwMF6IlY2lfu5eKUE39ygWdp4WuunefhxMLgP2sB
         W8PYyB0eB7GQujyD/R5ApnlR3R9BpVFqiQVTt81f27Nxomgn9UOzCEkmKStGD9FGeUb4
         HKojZfSwvPsj+ivKxdlPl1JZ4Z3bRU8gC45rYT/Cpnbb+3A6F3uVxMRb5vH9yCrv97CS
         ELjymNjnMuHd3SCqduY28XP+UM75uqGKMFnVne/VqAekE9MBpVlefYvcAlGk9Jk9eUBF
         4h9nA7/U30CkX2HNVqAJmVr3mSKVVIXDaPEhRQpeNYi0kbyTS5wYsx0Gu2j2tJpZ9F7w
         TTUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=nxsq3mYQfT8TSMKFYDwSPeWmp3gy8uwIjz9pCZKxPZU=;
        b=SSkdYUQIGBYXQoYXzXA2MyjpWOXMvV53BCshFiWcOeAywa6wCr8nUfMjuAIlTKVc0j
         kWKfsHs8nY1l3KrHB/h/t5RkvAVqypb3zMzSslEHP3aqO21jBCDqT27e3uwxyg/9TQQu
         dZPnlChm2iLftnCXMr5S9OkYUfi1pbRcctsuQGk9/6bP3yfjrnlBT2qpIqRTCdUy/nPJ
         nbkHumMnAAZTQOK1rxXTsvr57aG4vKBeP6bNSxc3Fk89pvLc/7fgtHb7FSFVLSOhR/B9
         pRzEB7vLd+Q9gU6b1KHbCmXgBeLHS1rgkenwnob7eYQPAIe2ABfpfa3wccbSaf7ub1TW
         rfOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="PwWWi/6z";
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k37sor20237533pgb.78.2019.02.12.10.23.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 10:23:38 -0800 (PST)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="PwWWi/6z";
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=nxsq3mYQfT8TSMKFYDwSPeWmp3gy8uwIjz9pCZKxPZU=;
        b=PwWWi/6z/KLx8kp9wjrAUlk1y9SQcQBpzqLI155xbQuh2NASaJrqCN5SSi//wUVc1t
         m3IZF6bQ0tcP181OqJfOC4PP5/jFvvVbmxqDrfbignDy8hOUrbxl+8jnwbZeoolbLdL4
         XEz0GAUuJKq9evlAyfWx2172mzsxDQi2dKwmA/IQe/S8JkBksQoSmUGVq1jtWhmSgJc0
         S24uEzPuL1T0dRYazHcnumWpjkpZRALizgsdThj7fKm4E8IDJyI3bRVvVr7yy3kI1ZNG
         wlVU/cnXIyVdyyBk6OVe0QBKrhyRc6Vl+YvVzbEghLWC6V5qmdIl7zdcaTSyrxQzEDjh
         Jqzw==
X-Google-Smtp-Source: AHgI3IaRR3twVY25CJj/D8rBGyc9tBMWkA30qmXX+UKb5QbpMaxH737L2/uz8wJqnvc1p4BG6pttIw==
X-Received: by 2002:a63:d052:: with SMTP id s18mr4726523pgi.11.1549995817579;
        Tue, 12 Feb 2019 10:23:37 -0800 (PST)
Received: from [10.33.115.182] ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id n72sm22979040pfg.13.2019.02.12.10.23.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 10:23:36 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2 05/20] x86/alternative: initializing temporary mm for
 patching
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <CALCETrXE0n4BrkX2ZLDJjdLqD-N_WwSZHt=S2KKBrTV6Zt5Teg@mail.gmail.com>
Date: Tue, 12 Feb 2019 10:23:35 -0800
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
Message-Id: <570C76C6-DDD2-49C4-8DAF-E8CFEAA21081@gmail.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-6-rick.p.edgecombe@intel.com>
 <162C6C29-CD81-46FE-9A54-6ED05A93A9CB@gmail.com>
 <00649AE8-69C0-4CD2-A916-B8C8F0F5DAC3@amacapital.net>
 <6FE10C97-25FF-4E99-A96A-465CBACA935B@gmail.com>
 <CALCETrVaBaorbOA8QE=Pk=C+PfXZAz0-aX_3O8Y=nJV4QKELbw@mail.gmail.com>
 <3EA322C6-5645-4900-AEC6-97FC05716F75@gmail.com>
 <CALCETrXE0n4BrkX2ZLDJjdLqD-N_WwSZHt=S2KKBrTV6Zt5Teg@mail.gmail.com>
To: Andy Lutomirski <luto@kernel.org>
X-Mailer: Apple Mail (2.3445.102.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Feb 11, 2019, at 2:47 PM, Andy Lutomirski <luto@kernel.org> wrote:
>=20
> On Mon, Feb 11, 2019 at 11:18 AM Nadav Amit <nadav.amit@gmail.com> =
wrote:
>>=20
>> +
>> +       /*
>> +        * If breakpoints are enabled, disable them while the =
temporary mm is
>> +        * used - they do not belong and might cause wrong signals or =
crashes.
>> +        */
>=20
> Maybe clarify this?  Add some mention that the specific problem is
> that user code could set a watchpoint on an address that is also used
> in the temporary mm.
>=20
> Arguably we should not disable *kernel* breakpoints a la perf, but
> that seems like quite a minor issue, at least as long as
> use_temporary_mm() doesn't get wider use.  But a comment that this
> also disables perf breakpoints and that this could be undesirable
> might be in order as well.

I think that in the future there may also be security benefits for =
disabling
breakpoints when you are in a sensitive code-block, for instance when =
you
poke text, to prevent the control flow from being hijacked (by =
exploiting a
bug in the debug exception handler). Some additional steps need to be =
taken
for that to be beneficial so I leave it out of the comment for now.

Anyhow, how about this:

-- >8 --

From: Nadav Amit <namit@vmware.com>
Date: Mon, 11 Feb 2019 03:07:08 -0800
Subject: [PATCH] x86/mm: Save DRs when loading a temporary mm

Prevent user watchpoints from mistakenly firing while the temporary mm
is being used. As the addresses that of the temporary mm might overlap
those of the user-process, this is necessary to prevent wrong signals
or worse things from happening.

Cc: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
---
 arch/x86/include/asm/mmu_context.h | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/arch/x86/include/asm/mmu_context.h =
b/arch/x86/include/asm/mmu_context.h
index d684b954f3c0..0d6c72ece750 100644
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
@@ -380,6 +382,22 @@ static inline temp_mm_state_t =
use_temporary_mm(struct mm_struct *mm)
 	lockdep_assert_irqs_disabled();
 	state.prev =3D this_cpu_read(cpu_tlbstate.loaded_mm);
 	switch_mm_irqs_off(NULL, mm, current);
+
+	/*
+	 * If breakpoints are enabled, disable them while the temporary =
mm is
+	 * used. Userspace might set up watchpoints on addresses that =
are used
+	 * in the temporary mm, which would lead to wrong signals being =
sent or
+	 * crashes.
+	 *
+	 * Note that breakpoints are not disabled selectively, which =
also causes
+	 * kernel breakpoints (e.g., perf's) to be disabled. This might =
be
+	 * undesirable, but still seems reasonable as the code that runs =
in the
+	 * temporary mm should be short.
+	 */
+	state.bp_enabled =3D hw_breakpoint_active();
+	if (state.bp_enabled)
+		hw_breakpoint_disable();
+
 	return state;
 }
=20
@@ -387,6 +405,13 @@ static inline void =
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
2.17.1=

