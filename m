Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5955C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 13:12:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 530B620850
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 13:12:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="P3PdHQt7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 530B620850
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6C056B0005; Mon, 18 Mar 2019 09:12:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1A456B0006; Mon, 18 Mar 2019 09:12:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE3116B0007; Mon, 18 Mar 2019 09:12:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7806B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:12:02 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d10so18535040pgv.23
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 06:12:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=epSZyqBe4Y/OKKkFIQZrTHU48PlN6fQS/KXlKAwvNCI=;
        b=AlNh+4m3ShNQ21s+DRSgkYZpejtZjLU6Iqz6R7t+wXMt7ZteV5cWTgqNmHLkZOjmYK
         /udOV6nBmiZYdToNNAm9vaERNtrRdkiMme10HI2Lt6ljpa24pd20QFMDXfCe8Q3nLn7S
         oVf9OavmdE3er7LE0Hmh1CWdVKMo+xpr9IHOWRVwr0IvgLhFKShGz7ptF3Opf2wthrRs
         qzIuB6O5GMBFnfsB+qDsqnhHYuCiaGmt5Nb/RqCfFP56iR7OJlqocxVyZ+jaHDtc2b1J
         wYp+k3c5Ay8gQ700tiJi5R84uvl4FJ6klpQzMv+mFjoSNtPyNftBnCRAJnuggSiDqh76
         6baw==
X-Gm-Message-State: APjAAAU2tzmz2lqZtNfpq+ixWSPAwDtXjNkatVuEPuheEBbnMr+a8nE1
	csTjcZe6sEJKSEtr7GTiWnWMzcPcfXqjMjGlyaLcf1z1Q5Wgh2UgwAClcZvAn6Ad5v4CEwYCF7J
	k5BBlt2u06N7G6EM63EFNwpdYzSHdy0kAok75P0BY0Cs231h20X2j9OrrDBRBRjTFAw==
X-Received: by 2002:a17:902:ab95:: with SMTP id f21mr20084081plr.188.1552914722236;
        Mon, 18 Mar 2019 06:12:02 -0700 (PDT)
X-Received: by 2002:a17:902:ab95:: with SMTP id f21mr20084004plr.188.1552914721033;
        Mon, 18 Mar 2019 06:12:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552914721; cv=none;
        d=google.com; s=arc-20160816;
        b=CnfTOpTxPDJCxBZTIpF2zKiXexKesY05d1mL467Bw95K0GZO+jCQnx6Z1a88BFlNLd
         BDxSfIlU24N17MIuKomghWpdvoyP6tv5SSu5d6TrJ5aSa6y4JQq0BGPzH+OGJpMBZrIJ
         o3NMUDt5w78okvlb8TgWl3XMd8h/fTmxxI0OB1P6nhxDFMPentHDjyoRvlmZbRTRzNC6
         C6yawxmbj9fVAk87RGangMPVIn+G48dOde7/F2Ph4Nuv5esnc6TjGCzC49cacrfspsgO
         SsQwnilVhBlXp+ufhGhgUUCxGLStU7nZakALfBPyzZhBDoxga1mUNaCd2fRlHs0ijA/o
         8XtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=epSZyqBe4Y/OKKkFIQZrTHU48PlN6fQS/KXlKAwvNCI=;
        b=rDDhd+nN/tVs3vTuY3FnwOqkDAZFJUv8zuE6ht9U+2uxc/IZA0VeLcPHxfQviwPuKA
         ekXVWbfcJ+BURqGbqZHzTAjN+Xpq71SkZFAoiB7GRpcUenZhOVySmtnqcWkhjoXU1gLH
         lmsLg/MVgG5KuEZB6zEmQX5Wbs9+coV/FkgWC7R56dGCL5HKOx5Em4xk1cXbLYzFu3ya
         QQUVZx+a02jTGbn0HuQV4QhBjnIBJnHlbvvM4s/WjaNOypIyjEKP5CfTyztynivF+eJQ
         P5huhnrGhBJdTSw7rGqWHBkzBbtYze/gijlyqzO7m1H35WWzM1iONoRPBXeksU1d6jdM
         26Nw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=P3PdHQt7;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a10sor14396775pgt.24.2019.03.18.06.12.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 06:12:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=P3PdHQt7;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=epSZyqBe4Y/OKKkFIQZrTHU48PlN6fQS/KXlKAwvNCI=;
        b=P3PdHQt7xFqZZ3OrRYOWBumt+a10yvZZMe1ahnZ2OGcnXfGyJJFIc2Nb8lvZ1eqff4
         2Pf3/a37IMdsjTJvg8yZIdYlXXtA+u9R1nUXlnqxgvTcan5dBu3bKAFJ12vFUq8LYM69
         rXxz45yqcaFS2CRPQ3W1ojfgDx8Sa0oilfDVLK6Yxc/nGYKhB1oOWK505pPCwQSxpwaR
         EFKBroNNEWD6Oe94kwuZEJMakVgDICxInMsHhkEnvuZnJUNaYMUcJsseebsl58Kr62PY
         r4/L9fjQ615HRjni091pU8NN0zsXcHSGyGGzPKRhhr27ZgOiVu1plt9p95gldYBxHQdQ
         /jIA==
X-Google-Smtp-Source: APXvYqxkDF5fYpEH3Vs9ly9eilzCAQ4eFXUJCbCmr4F2nw4zNTdJM2I6GFk4D2mim2UUO7TV8sZWRVg+GwdnMP3xaNA=
X-Received: by 2002:a65:6651:: with SMTP id z17mr16746057pgv.95.1552914720458;
 Mon, 18 Mar 2019 06:12:00 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com> <355e7c0dadaa2bb79d22e0b7aac7e4efc1114d49.1552679409.git.andreyknvl@google.com>
 <20190315161414.4b31fb03@gandalf.local.home>
In-Reply-To: <20190315161414.4b31fb03@gandalf.local.home>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 18 Mar 2019 14:11:48 +0100
Message-ID: <CAAeHK+w5L+yD-9c94vgX3KcQuzyaKhoDemgGcZ8SJWpc7GhE9g@mail.gmail.com>
Subject: Re: [PATCH v11 10/14] tracing, arm64: untag user pointers in seq_print_user_ip
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	netdev <netdev@vger.kernel.org>, bpf@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 15, 2019 at 9:14 PM Steven Rostedt <rostedt@goodmis.org> wrote:
>
> On Fri, 15 Mar 2019 20:51:34 +0100
> Andrey Konovalov <andreyknvl@google.com> wrote:
>
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > seq_print_user_ip() uses provided user pointers for vma lookups, which
> > can only by done with untagged pointers.
> >
> > Untag user pointers in this function.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  kernel/trace/trace_output.c |  5 +++--
> >  p                           | 45 +++++++++++++++++++++++++++++++++++++
> >  2 files changed, 48 insertions(+), 2 deletions(-)
> >  create mode 100644 p
> >
> > diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
> > index 54373d93e251..6376bee93c84 100644
> > --- a/kernel/trace/trace_output.c
> > +++ b/kernel/trace/trace_output.c
> > @@ -370,6 +370,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
> >  {
> >       struct file *file = NULL;
> >       unsigned long vmstart = 0;
> > +     unsigned long untagged_ip = untagged_addr(ip);
> >       int ret = 1;
> >
> >       if (s->full)
> > @@ -379,7 +380,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
> >               const struct vm_area_struct *vma;
> >
> >               down_read(&mm->mmap_sem);
> > -             vma = find_vma(mm, ip);
> > +             vma = find_vma(mm, untagged_ip);
> >               if (vma) {
> >                       file = vma->vm_file;
> >                       vmstart = vma->vm_start;
> > @@ -388,7 +389,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
> >                       ret = trace_seq_path(s, &file->f_path);
> >                       if (ret)
> >                               trace_seq_printf(s, "[+0x%lx]",
> > -                                              ip - vmstart);
> > +                                              untagged_ip - vmstart);
> >               }
> >               up_read(&mm->mmap_sem);
> >       }
> > diff --git a/p b/p
> > new file mode 100644
> > index 000000000000..9d6fa5386e55
> > --- /dev/null
> > +++ b/p
> > @@ -0,0 +1,45 @@
> > +commit 1fa6fadf644859e8a6a8ecce258444b49be8c7ee
> > +Author: Andrey Konovalov <andreyknvl@google.com>
> > +Date:   Mon Mar 4 17:20:32 2019 +0100
> > +
> > +    kasan: fix coccinelle warnings in kasan_p*_table
> > +
> > +    kasan_p4d_table, kasan_pmd_table and kasan_pud_table are declared as
> > +    returning bool, but return 0 instead of false, which produces a coccinelle
> > +    warning. Fix it.
> > +
> > +    Fixes: 0207df4fa1a8 ("kernel/memremap, kasan: make ZONE_DEVICE with work with KASAN")
> > +    Reported-by: kbuild test robot <lkp@intel.com>
> > +    Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>
> Did you mean to append this commit to this patch?

No, did it by mistake. Will remove in v12, thanks for noticing!

>
> -- Steve
>
> > +
> > +diff --git a/mm/kasan/init.c b/mm/kasan/init.c
> > +index 45a1b5e38e1e..fcaa1ca03175 100644
> > +--- a/mm/kasan/init.c
> > ++++ b/mm/kasan/init.c
> > +@@ -42,7 +42,7 @@ static inline bool kasan_p4d_table(pgd_t pgd)
> > + #else
> > + static inline bool kasan_p4d_table(pgd_t pgd)
> > + {
> > +-    return 0;
> > ++    return false;
> > + }
> > + #endif
> > + #if CONFIG_PGTABLE_LEVELS > 3
> > +@@ -54,7 +54,7 @@ static inline bool kasan_pud_table(p4d_t p4d)
> > + #else
> > + static inline bool kasan_pud_table(p4d_t p4d)
> > + {
> > +-    return 0;
> > ++    return false;
> > + }
> > + #endif
> > + #if CONFIG_PGTABLE_LEVELS > 2
> > +@@ -66,7 +66,7 @@ static inline bool kasan_pmd_table(pud_t pud)
> > + #else
> > + static inline bool kasan_pmd_table(pud_t pud)
> > + {
> > +-    return 0;
> > ++    return false;
> > + }
> > + #endif
> > + pte_t kasan_early_shadow_pte[PTRS_PER_PTE] __page_aligned_bss;
>

