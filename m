Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28B13C43387
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 20:47:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7D7F20851
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 20:47:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="1v/yNJqB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7D7F20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BFD18E0004; Thu, 17 Jan 2019 15:47:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36DFE8E0002; Thu, 17 Jan 2019 15:47:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 285048E0004; Thu, 17 Jan 2019 15:47:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id DB6A18E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 15:47:52 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o17so6923165pgi.14
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:47:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=xTOYNcdZ1AfYRoSOgFWyoZ4zslXICLkJkJfxISpksD8=;
        b=Yy/UfC9UxgO+paIWmkNbQIAZTzSA6KMWlnJfaWNGzQPHOh9qczLOiHLKUBluGEAyLJ
         Dq4EuRrhFk2fJi20DxEjXqmSQ6qYHtzexKnr0o0+tMO3XOaLMRgHAss5y15DSJLBuG6A
         MUNy1i2nKq+ujFVcC0AlTLAXwQlv1YPzy5qd5usd5qmXpqef17d4LUaUjlm2l4p2L38p
         Cu07URu3d6PVGC4BFdsT3BYd/wuz11Q5wsIQRgLq6FcLjc0hq3nLjhjqpN4TjaLvce0M
         wakw3LV1/GjQNx2b1H6ueT5ieNDfPwb87EK2+YP+WqwvPOpubjDzd1SPT+I+BG4OjhDN
         6HJA==
X-Gm-Message-State: AJcUukerAUvfloD9K4CTmAwe13R037fMKwsPPS/e6PeYe17wUTjwHRzx
	fo+mkajq/UgOd7kpXgykDcoHIh3m5JQWlrkrUntUmXlq7cBmyzk5ZWplvd2n+5osu+k3xZcwmy6
	izAD4iNdkj6IZzW3UvS4sX9QTgiROqh90avHMYMtdWYix4gbMz2mt59PXlULTiBT2Gg==
X-Received: by 2002:a62:7086:: with SMTP id l128mr16394756pfc.68.1547758072542;
        Thu, 17 Jan 2019 12:47:52 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7rRwzGHyCTVYF6omuylgDZK3M1ZQwkI/76EH6JjJfnvanza+KsOSWMxnU5YhKOW4Ve3NER
X-Received: by 2002:a62:7086:: with SMTP id l128mr16394707pfc.68.1547758071429;
        Thu, 17 Jan 2019 12:47:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547758071; cv=none;
        d=google.com; s=arc-20160816;
        b=GH/33mldUc0jrz4+dSj9Ln58KWxYVt531s/pgSUzNDhsDQjC56+bfPxOTOohOd+qCZ
         QD7iv56kKSeN4z0XA6NXe2d9xCxXkAguoCSWlf4WqEotNEnWr0uKgIWVY2baIrWsxPMs
         C7klKSouQ4pmGSvZAs8lRI5tZEn2xDC/NPjmW1DoyJ4QY4SSJUL83mf80QaZgwWikvV9
         FY1mLcC9O4BgTy2gOD8hZ2jr1ldNN+7Hf+lw3bpjmOJelnijYTJP4WO9r8/K8vceUYZf
         GVvTJhmky1D+I4K5kj6w1gXgB6LQS0Dt/yKHSRw45S94XjnjRkDMwTdRNi36X07DeUXA
         pzkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=xTOYNcdZ1AfYRoSOgFWyoZ4zslXICLkJkJfxISpksD8=;
        b=S/J09ySYwIA/2JN3X2d0ZMszJSb2V/N5ArSKVDenuwvJuPAXtdKWayXUiZ/7O2vAlg
         nchrYmh5n31lffkaHtCSUoWRDp6C5jboOxvfquk0h1UiAMA6G3D9Ye/LnojwOq1J7qYc
         J56z75gsftCzd5De5PpHQ7i6VlDtNM5ZG1TxkqbhCHSE8zN2W7k9GRTW9P3VobqtNaV9
         it16JMImPMzBOs/onPexViAwmvJXKiHWmDI5OPPYimCqjbk+Hkum2t9jpkc9CdG0uymb
         3HY+xUiviTn8CvSfWaxYRwVDAFwwgV6cKDLqSYnMIxr2xyKewD9qYoqLIAv+aLdntv5N
         FtRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="1v/yNJqB";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s191si2523886pfs.53.2019.01.17.12.47.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 12:47:51 -0800 (PST)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="1v/yNJqB";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f49.google.com (mail-wm1-f49.google.com [209.85.128.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 71B8A2146F
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 20:47:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1547758070;
	bh=n8JMekFCbtwr62FzDCJJoj5l06UUzHpxnzcg5AUI7TM=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=1v/yNJqBMgzweIaFgEWtP2lvGXeclrXJB1t0pXSbhZgFbyyQjphalnJPKjN1b7XGp
	 8qNqL7JXfylXL1R7pc0XXdlb1KZGx/cZBFV5Up9Dgj4W8zDq2uH0g8kHugPIVJxxv3
	 zqQmR8daNSixtMx2XuYELmKrlF860GrbRVCRB0Yo=
Received: by mail-wm1-f49.google.com with SMTP id p6so2495826wmc.1
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:47:50 -0800 (PST)
X-Received: by 2002:a1c:b1d5:: with SMTP id a204mr13844935wmf.32.1547758068833;
 Thu, 17 Jan 2019 12:47:48 -0800 (PST)
MIME-Version: 1.0
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
 <20190117003259.23141-7-rick.p.edgecombe@intel.com> <CALCETrUMAsXoZogEJg7ssv0CO56vzBV2C7VotmWcwNM7iH9Wqw@mail.gmail.com>
In-Reply-To: <CALCETrUMAsXoZogEJg7ssv0CO56vzBV2C7VotmWcwNM7iH9Wqw@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 17 Jan 2019 12:47:37 -0800
X-Gmail-Original-Message-ID: <CALCETrXQ6uxzB3JvO14sEyMA21RcWCbwicL4nUdPBG8KAunxwg@mail.gmail.com>
Message-ID:
 <CALCETrXQ6uxzB3JvO14sEyMA21RcWCbwicL4nUdPBG8KAunxwg@mail.gmail.com>
Subject: Re: [PATCH 06/17] x86/alternative: use temporary mm for text poking
To: Andy Lutomirski <luto@kernel.org>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>, Ingo Molnar <mingo@redhat.com>, 
	LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, 
	"H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, 
	Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com, 
	linux-integrity <linux-integrity@vger.kernel.org>, 
	LSM List <linux-security-module@vger.kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	Kristen Carlson Accardi <kristen@linux.intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, 
	Nadav Amit <namit@vmware.com>, Kees Cook <keescook@chromium.org>, 
	Dave Hansen <dave.hansen@intel.com>, Masami Hiramatsu <mhiramat@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117204737.HcnslBgCHMJ09htWQ-UUrErwghAI4gx2EniwsZDmDFM@z>

On Thu, Jan 17, 2019 at 12:27 PM Andy Lutomirski <luto@kernel.org> wrote:
>
> On Wed, Jan 16, 2019 at 4:33 PM Rick Edgecombe
> <rick.p.edgecombe@intel.com> wrote:
> >
> > From: Nadav Amit <namit@vmware.com>
> >
> > text_poke() can potentially compromise the security as it sets temporary
> > PTEs in the fixmap. These PTEs might be used to rewrite the kernel code
> > from other cores accidentally or maliciously, if an attacker gains the
> > ability to write onto kernel memory.
>
> i think this may be sufficient, but barely.
>
> > +       pte_clear(poking_mm, poking_addr, ptep);
> > +
> > +       /*
> > +        * __flush_tlb_one_user() performs a redundant TLB flush when PTI is on,
> > +        * as it also flushes the corresponding "user" address spaces, which
> > +        * does not exist.
> > +        *
> > +        * Poking, however, is already very inefficient since it does not try to
> > +        * batch updates, so we ignore this problem for the time being.
> > +        *
> > +        * Since the PTEs do not exist in other kernel address-spaces, we do
> > +        * not use __flush_tlb_one_kernel(), which when PTI is on would cause
> > +        * more unwarranted TLB flushes.
> > +        *
> > +        * There is a slight anomaly here: the PTE is a supervisor-only and
> > +        * (potentially) global and we use __flush_tlb_one_user() but this
> > +        * should be fine.
> > +        */
> > +       __flush_tlb_one_user(poking_addr);
> > +       if (cross_page_boundary) {
> > +               pte_clear(poking_mm, poking_addr + PAGE_SIZE, ptep + 1);
> > +               __flush_tlb_one_user(poking_addr + PAGE_SIZE);
> > +       }
>
> In principle, another CPU could still have the old translation.  Your
> mutex probably makes this impossible, but it makes me nervous.
> Ideally you'd use flush_tlb_mm_range(), but I guess you can't do that
> with IRQs off.  Hmm.  I think you should add an inc_mm_tlb_gen() here.
> Arguably, if you did that, you could omit the flushes, but maybe
> that's silly.
>
> If we start getting new users of use_temporary_mm(), we should give
> some serious thought to the SMP semantics.
>
> Also, you're using PAGE_KERNEL.  Please tell me that the global bit
> isn't set in there.
>

Much better solution: do unuse_temporary_mm() and *then*
flush_tlb_mm_range().  This is entirely non-sketchy and should be just
about optimal, too.

--Andy

