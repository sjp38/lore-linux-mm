Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87D0DC4321B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 17:49:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 005E020685
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 17:49:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="AeH32e9g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 005E020685
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB3D06B0003; Thu, 25 Apr 2019 13:49:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E63956B0005; Thu, 25 Apr 2019 13:49:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D522E6B0006; Thu, 25 Apr 2019 13:49:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2E66B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:49:43 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g1so410567pfo.2
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 10:49:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=m5za7n1oEjeLIknb6phOrUrhUG4/hlL+Pwkng0870GE=;
        b=QWpPKV/4WQjVidEyuCTmFvObGnD3U9nqUU9kdy/kwosDtSzb11ImtHllNB4BcgFN8g
         QnWI6YhyTK6y1cUiiv9T5UHaEZpdoQYa3pAvnKVqpoGBougqo2xMBnB7aAS0GzpShFGw
         5Ir5hQXF2p7WDXrHR3mOZR+tdQFEDVGCg9W54SOQEEfeU3fakXV3mA/qvRiRiKfk9Ets
         1Lu3ZAA9tTNlF3QZqXzK0tmACzbQojapnSR2qQ0UYxvxewfFYyfL1RhEN431g/b+SCrE
         Ynd/80h1fuwEbBQnsBYVzsUhw37Hu256QvV3AqNjY7sPUp27MceWcwGTVQAf7auU8K8a
         AqRg==
X-Gm-Message-State: APjAAAVhEVWIA4nCVLGGnDChEfvhjmIUqkg6uu2NvqziJj3DES2iHTEg
	ZbStIZmiANTqoDYdW6jZyHcpwtfPkt0IDAJlNZgaZY8aiEunGOPZ9FgA8XOD4wjut36RCTqRA73
	HbMeg0PqPVz4Hf3Skdn694Wuu3wauNgTdKynOI/Y9x3AlTkAmr22BEY64laEmIKi85A==
X-Received: by 2002:a62:f20e:: with SMTP id m14mr43138485pfh.228.1556214582771;
        Thu, 25 Apr 2019 10:49:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRMqCi5AUM+P8ZCJ5pZ8rBT3+HHSb5oHdhd3JA2XbSh5vuJw3ZJgXhS2RJrZidVNVqdcH3
X-Received: by 2002:a62:f20e:: with SMTP id m14mr43138416pfh.228.1556214582035;
        Thu, 25 Apr 2019 10:49:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556214582; cv=none;
        d=google.com; s=arc-20160816;
        b=iYKkHMk9+0l2KtX73n9wsgAUXi777YQLkQF+agKecjDhwSn9aefEKfmOgZJ7B7jQSo
         i0chhTFe1VhqqU6/FjE3UGQrcxar7bs9Vct9KjYOxyfFvetCwiSP4Ou+hd8Ix2ET1x1s
         TTTXpGySpli1/jVD7jU1pD9Y9jf6wB/XROasPDcbME0oBX9RnG+SD5m+XwySjdD/DVSN
         jTm5oK3vTy8FSnX+6zuZ0kdtFErOaIQR0E5djV718heNGXUrzSXGj6iJxtMcFvdkAJan
         QaP7zYg8nSS+kkxJqG/8cMsTIWj9KTQ2OYcq7MazevgO43Fyp3bc1eYTE7Ig/bh38Cwt
         M6IQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=m5za7n1oEjeLIknb6phOrUrhUG4/hlL+Pwkng0870GE=;
        b=jL54tGxqvMPxtByP7lAdEZymIB8fVBjlldEeMtGeaUWf1YW+fz9QE3whEfdHkQ0B/n
         Tq5ZdUHQKWJ/8rCoFA/W4KpF9u7l0IC2Wo/YM011ktKjJ5AIXeHth+lX84L5Ps04cuGp
         bVpU7dI39aORkm7vpJnrqLAG8KzkYKQzuxIREo2RMHVAwLCPBkt37yb4nz9JfiYnXgXv
         H3n42BHVyPiwbr41hVgspTw1A00hcyqlyZhZkb2+AxDPIg6jHDP5atczJPRvYxuPdvaz
         IifVwN+uAvN2vTqfc1LSIQmKENMHwaunw2pusgp41CT45YVEWehEZ04PFCeE+ROAeHgI
         ikLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AeH32e9g;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p65si6332094pfa.48.2019.04.25.10.49.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 10:49:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AeH32e9g;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f42.google.com (mail-wm1-f42.google.com [209.85.128.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1FCB021530
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:49:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556214582;
	bh=k7j/1g7qfQNqTMzadjTDghyn+ZldaWg22WWJRpeAVjE=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=AeH32e9gKFK/kCCx4QBmNaIi9VoX2FsuBBARmXxzEEqAq3z+dTBgxGXKkfzqgpS2g
	 FQvNLn104ZeAtZnGYEoMQykDgBtX2JkgpaAcwQf50dFeJYDfVGi/ds5EZelPMhPuJQ
	 LX+mBbOazigTfZCu8jlaN1AH+IO5vQx7DoIF8kgQ=
Received: by mail-wm1-f42.google.com with SMTP id v14so430650wmf.2
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 10:49:41 -0700 (PDT)
X-Received: by 2002:a7b:c182:: with SMTP id y2mr4262844wmi.83.1556214579825;
 Thu, 25 Apr 2019 10:49:39 -0700 (PDT)
MIME-Version: 1.0
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
 <20190422185805.1169-4-rick.p.edgecombe@intel.com> <20190425162620.GA5199@zn.tnic>
 <B7809434-CEBE-4664-ACE7-BA2412163CC4@gmail.com>
In-Reply-To: <B7809434-CEBE-4664-ACE7-BA2412163CC4@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 25 Apr 2019 10:49:27 -0700
X-Gmail-Original-Message-ID: <CALCETrVkEJuTwYnC4kc7Xk_KEeKGGtuDErNyfL=Oa_CZp+=yOA@mail.gmail.com>
Message-ID: <CALCETrVkEJuTwYnC4kc7Xk_KEeKGGtuDErNyfL=Oa_CZp+=yOA@mail.gmail.com>
Subject: Re: [PATCH v4 03/23] x86/mm: Introduce temporary mm structs
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, Rick Edgecombe <rick.p.edgecombe@intel.com>, 
	Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, 
	"H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, 
	Damian Tometzki <linux_dti@icloud.com>, linux-integrity <linux-integrity@vger.kernel.org>, 
	LSM List <linux-security-module@vger.kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	Kristen Carlson Accardi <kristen@linux.intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, 
	Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>, 
	Borislav Petkov <bp@alien8.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 10:37 AM Nadav Amit <nadav.amit@gmail.com> wrote:
>
> > On Apr 25, 2019, at 9:26 AM, Borislav Petkov <bp@alien8.de> wrote:
> >
> > On Mon, Apr 22, 2019 at 11:57:45AM -0700, Rick Edgecombe wrote:
> >> From: Andy Lutomirski <luto@kernel.org>
> >>
> >> Using a dedicated page-table for temporary PTEs prevents other cores
> >> from using - even speculatively - these PTEs, thereby providing two
> >> benefits:
> >>
> >> (1) Security hardening: an attacker that gains kernel memory writing
> >> abilities cannot easily overwrite sensitive data.
> >>
> >> (2) Avoiding TLB shootdowns: the PTEs do not need to be flushed in
> >> remote page-tables.
> >>
> >> To do so a temporary mm_struct can be used. Mappings which are private
> >> for this mm can be set in the userspace part of the address-space.
> >> During the whole time in which the temporary mm is loaded, interrupts
> >> must be disabled.
> >>
> >> The first use-case for temporary mm struct, which will follow, is for
> >> poking the kernel text.
> >>
> >> [ Commit message was written by Nadav Amit ]
> >>
> >> Cc: Kees Cook <keescook@chromium.org>
> >> Cc: Dave Hansen <dave.hansen@intel.com>
> >> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> >> Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
> >> Tested-by: Masami Hiramatsu <mhiramat@kernel.org>
> >> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> >> Signed-off-by: Nadav Amit <namit@vmware.com>
> >> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> >> ---
> >> arch/x86/include/asm/mmu_context.h | 33 ++++++++++++++++++++++++++++++
> >> 1 file changed, 33 insertions(+)
> >>
> >> diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm=
/mmu_context.h
> >> index 19d18fae6ec6..d684b954f3c0 100644
> >> --- a/arch/x86/include/asm/mmu_context.h
> >> +++ b/arch/x86/include/asm/mmu_context.h
> >> @@ -356,4 +356,37 @@ static inline unsigned long __get_current_cr3_fas=
t(void)
> >>      return cr3;
> >> }
> >>
> >> +typedef struct {
> >> +    struct mm_struct *prev;
> >> +} temp_mm_state_t;
> >> +
> >> +/*
> >> + * Using a temporary mm allows to set temporary mappings that are not=
 accessible
> >> + * by other cores. Such mappings are needed to perform sensitive memo=
ry writes
> >
> > s/cores/CPUs/g
> >
> > Yeah, the concept of a thread of execution we call a CPU in the kernel,
> > I'd say. No matter if it is one of the hyperthreads or a single thread
> > in core.
> >
> >> + * that override the kernel memory protections (e.g., W^X), without e=
xposing the
> >> + * temporary page-table mappings that are required for these write op=
erations to
> >> + * other cores.
> >
> > Ditto.
> >
> >> Using temporary mm also allows to avoid TLB shootdowns when the
> >
> > Using a ..
> >
> >> + * mapping is torn down.
> >> + *
> >
> > Nice commenting.
> >
> >> + * Context: The temporary mm needs to be used exclusively by a single=
 core. To
> >> + *          harden security IRQs must be disabled while the temporary=
 mm is
> >                             ^
> >                             ,
> >
> >> + *          loaded, thereby preventing interrupt handler bugs from ov=
erriding
> >> + *          the kernel memory protection.
> >> + */
> >> +static inline temp_mm_state_t use_temporary_mm(struct mm_struct *mm)
> >> +{
> >> +    temp_mm_state_t state;
> >> +
> >> +    lockdep_assert_irqs_disabled();
> >> +    state.prev =3D this_cpu_read(cpu_tlbstate.loaded_mm);
> >> +    switch_mm_irqs_off(NULL, mm, current);
> >> +    return state;
> >> +}
> >> +
> >> +static inline void unuse_temporary_mm(temp_mm_state_t prev)
> >> +{
> >> +    lockdep_assert_irqs_disabled();
> >> +    switch_mm_irqs_off(NULL, prev.prev, current);
> >
> > I think this code would be more readable if you call that
> > temp_mm_state_t variable "temp_state" and the mm_struct pointer "mm" an=
d
> > then you have:
> >
> >       switch_mm_irqs_off(NULL, temp_state.mm, current);
> >
> > And above you'll have:
> >
> >       temp_state.mm =3D ...
>
> Andy, please let me know whether you are fine with this change and I=E2=
=80=99ll
> incorporate it.


I'm okay with it.

