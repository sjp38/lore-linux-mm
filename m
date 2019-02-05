Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6475FC282C4
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 00:16:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22FB520821
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 00:16:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="i0BXD7sC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22FB520821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFB088E006B; Mon,  4 Feb 2019 19:16:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A80C48E001C; Mon,  4 Feb 2019 19:16:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 923118E006B; Mon,  4 Feb 2019 19:16:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6652C8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 19:16:42 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id 71so2778423ita.6
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 16:16:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=qSNnKxL2nrnVRHFfZR4ZBMP/3M8ulDpQEArg97iOUuQ=;
        b=N/hFFVVBHVfNLs3kUZjI7HUu1NGwyONC+8mzkb2TZOU1kFQffIgqj02yJ2juZqwHqy
         xhBgMjarxOTqSiwSnT1hoXfXtolkqvXkxliDYD6IaXT/rxC4Z+YvPA0uRr9tny3SB5fC
         SCRi+CdKsMdLWYTYbSdmpYFKMBJMlxQeUd3sfw4YwoTLxZpOoQW4A4BBKrM2iWT8az0H
         GAhb9IFB0npsVpy7x9cNz0oteUOedeZ1fjryC7GIR89n00ch4yKH8zTOXw67uSHOHJbI
         auyardX3ZyBJNs0nl7W8yLwh8BKnhG9jMe8YwFwyoQCPmmGXjBQJ+QwjXNKXzvzm27ko
         Kxmw==
X-Gm-Message-State: AHQUAuYxwkPfPsfDnb/uVDb/ZX5K7oHbISTf78Y1UbtfjVHJA+R7w3Z2
	7hz8vxLV/R+h9ofs2Qh6+HGh5MBU2m09R3hB2x1psC/WhoiAokZwJRpfGgftjJQLJUyrMwRbo5+
	UUyLDU6csQOCeKeS2KVNQ3D2FT2qlMRa1HIYw6lL4Yf8Q85rsmvWY2D3Ohg5Rc6cCxVdN8CHeir
	UfU28j+FkBgrHhSYISBf5O0TVO63eCPYx1zloDFJBvTpXIv4COpa9xi0/jRDqsIG/5Sdhem/lxe
	ZJlU8k7LKSFUdY36UJUXtGrkvwTSzZpWMLwKDibBxUO45biAWRWyhOEwfiK2pxMvRfSRC4A7+Xt
	EeKwDs9/8x5tnVKYj/8YPzXE3Q9VhwVNEP6fXaUvJ04M0ycCJ97Y8zOV3DndNY/UsRVR4ChaDyP
	+
X-Received: by 2002:a24:9307:: with SMTP id y7mr1225984itd.38.1549325802139;
        Mon, 04 Feb 2019 16:16:42 -0800 (PST)
X-Received: by 2002:a24:9307:: with SMTP id y7mr1225964itd.38.1549325801324;
        Mon, 04 Feb 2019 16:16:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549325801; cv=none;
        d=google.com; s=arc-20160816;
        b=E/tzcoOF01TlrwT/OPPgdTVUSJTXdyYs3TRu+wO3Q8Vi9V0fzz+fa/ltxHDh27GCap
         9weRj+lQOL7OlkoXw6BliQYlxNuJqQp3/LpLoc+2FUw+a58TTNtIFfajX0M8v8/NmebM
         s6dJXNnQjIj8ebU9GQcWxL+r2++S7kslvhDlAZbepVMRpPenU3K7ZVKTRZzaZRNC0L5A
         E8Oe33EOk49EXI2wynM8hYd6NOdCysutWh8viysZ8aiWb5XuGkwZsGAOFgBtCJ3/tITu
         Ql2Nef8QuRcwkoKbZZaU0QPLOiPWpK8qZtdEuf7NLnqX8jIqGoidqDZ8pa3a72DouN4i
         xPXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=qSNnKxL2nrnVRHFfZR4ZBMP/3M8ulDpQEArg97iOUuQ=;
        b=dWuo6OiOWZjKmw7/xcC99mthbM+u0O2QHtLK3LG3/Q37GXmiG9S6tJSE+4qvESbowo
         +gALb5OxCNyVFCcy/PI25Kws7wYKD/Pq0UgJp7yRC6EZqw4Zn4yBH7BNgfCWlT/uT+79
         +9iR5tJew5pfUHtuvfWxrE+O8Lf1CYx1MO9+vNcdA1QGbyCB3xf/GhQ2HXxzMIsdNP+S
         oToldbB0H25tJ+0Vk2Yeaer/FLDQcEVR7jNRyMJD8ykH6ahBtFvCp8vMVOi1NTNNHVpr
         FH0+OPMCM4As5eiUUAaUx5g+gAy3FhFAEpuHg6ivbCT4Phrut0z8MZzHD7ZHwga00voF
         Kdog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=i0BXD7sC;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g3sor917814ioq.132.2019.02.04.16.16.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 16:16:41 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=i0BXD7sC;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=qSNnKxL2nrnVRHFfZR4ZBMP/3M8ulDpQEArg97iOUuQ=;
        b=i0BXD7sCTw60mTz87bTqRKrwoIRfL9tcSusnqahkqW3wxh9EvQv44ZJ/mOPb4TD2vk
         2BDWQPMmE6hBIwyNUnW8GqpTFZn4KtOj3bfpX43/nf4zw8RNbYZ4mrmzyUtxZ50qG7+H
         MzaSwANWZp7J6nlDiqb41Y+oKxUlIe8+4CSTCOYn7DOPcK7hEMwkkSc+HnbpArfcnBWF
         cG+WJF3wfAs2G5/m6ky3dDYeDYjo0zhjlp0xtYBVfrFB/0cVJy8Ls9kbvjzvWYPFTCw+
         RaMyESDoGyLG88y3N5k4y1ZQEiH4uEIICQsWCC7QTP6mkCAL9usPZmOQRV4Vk4oXbzjV
         b+tQ==
X-Google-Smtp-Source: AHgI3IasUi1d6DKjqWwba2iEtuRz2nVkg9wemn0IY9xsgg3CkC/EwdzV/Fj93eXRSD/RoycEYJaNSvJwU12Lxd09O+Q=
X-Received: by 2002:a5d:8889:: with SMTP id d9mr1418256ioo.68.1549325800850;
 Mon, 04 Feb 2019 16:16:40 -0800 (PST)
MIME-Version: 1.0
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181552.12095.46287.stgit@localhost.localdomain> <4E64E8CA-6741-47DF-87DE-88D01B01B15D@gmail.com>
 <c24dc2351f3dc2f0e0bdf552c6504851e6fa6c06.camel@linux.intel.com> <4DFBB378-8E7A-4905-A94D-D56B5FF6D42B@gmail.com>
In-Reply-To: <4DFBB378-8E7A-4905-A94D-D56B5FF6D42B@gmail.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 4 Feb 2019 16:16:29 -0800
Message-ID: <CAKgT0UevPXAG7xGzEur731-EJ0tOSGeg+AwugnRt6ugmfEKeLw@mail.gmail.com>
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory hints
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, kvm list <kvm@vger.kernel.org>, 
	Radim Krcmar <rkrcmar@redhat.com>, X86 ML <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>, bp@alien8.de, 
	Peter Anvin <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 4, 2019 at 4:03 PM Nadav Amit <nadav.amit@gmail.com> wrote:
>
> > On Feb 4, 2019, at 3:37 PM, Alexander Duyck <alexander.h.duyck@linux.in=
tel.com> wrote:
> >
> > On Mon, 2019-02-04 at 15:00 -0800, Nadav Amit wrote:
> >>> On Feb 4, 2019, at 10:15 AM, Alexander Duyck <alexander.duyck@gmail.c=
om> wrote:
> >>>
> >>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> >>>
> >>> Add guest support for providing free memory hints to the KVM hypervis=
or for
> >>> freed pages huge TLB size or larger. I am restricting the size to
> >>> huge TLB order and larger because the hypercalls are too expensive to=
 be
> >>> performing one per 4K page. Using the huge TLB order became the obvio=
us
> >>> choice for the order to use as it allows us to avoid fragmentation of=
 higher
> >>> order memory on the host.
> >>>
> >>> I have limited the functionality so that it doesn't work when page
> >>> poisoning is enabled. I did this because a write to the page after do=
ing an
> >>> MADV_DONTNEED would effectively negate the hint, so it would be wasti=
ng
> >>> cycles to do so.
> >>>
> >>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> >>> ---
> >>> arch/x86/include/asm/page.h |   13 +++++++++++++
> >>> arch/x86/kernel/kvm.c       |   23 +++++++++++++++++++++++
> >>> 2 files changed, 36 insertions(+)
> >>>
> >>> diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.=
h
> >>> index 7555b48803a8..4487ad7a3385 100644
> >>> --- a/arch/x86/include/asm/page.h
> >>> +++ b/arch/x86/include/asm/page.h
> >>> @@ -18,6 +18,19 @@
> >>>
> >>> struct page;
> >>>
> >>> +#ifdef CONFIG_KVM_GUEST
> >>> +#include <linux/jump_label.h>
> >>> +extern struct static_key_false pv_free_page_hint_enabled;
> >>> +
> >>> +#define HAVE_ARCH_FREE_PAGE
> >>> +void __arch_free_page(struct page *page, unsigned int order);
> >>> +static inline void arch_free_page(struct page *page, unsigned int or=
der)
> >>> +{
> >>> +   if (static_branch_unlikely(&pv_free_page_hint_enabled))
> >>> +           __arch_free_page(page, order);
> >>> +}
> >>> +#endif
> >>
> >> This patch and the following one assume that only KVM should be able t=
o hook
> >> to these events. I do not think it is appropriate for __arch_free_page=
() to
> >> effectively mean =E2=80=9Ckvm_guest_free_page()=E2=80=9D.
> >>
> >> Is it possible to use the paravirt infrastructure for this feature,
> >> similarly to other PV features? It is not the best infrastructure, but=
 at least
> >> it is hypervisor-neutral.
> >
> > I could probably tie this into the paravirt infrastructure, but if I
> > did so I would probably want to pull the checks for the page order out
> > of the KVM specific bits and make it something we handle in the inline.
> > Doing that I would probably make it a paravirtual hint that only
> > operates at the PMD level. That way we wouldn't incur the cost of the
> > paravirt infrastructure at the per 4K page level.
>
> If I understand you correctly, you =E2=80=9Ccomplain=E2=80=9D that this w=
ould affect
> performance.

It wasn't so much a "complaint" as an "observation". What I was
getting at is that if I am going to make it a PV operation I might set
a hard limit on it so that it will specifically only apply to huge
pages and larger. By doing that I can justify performing the screening
based on page order in the inline path and avoid any PV infrastructure
overhead unless I have to incur it.

> While it might be, you may want to check whether the already available
> tools can solve the problem:
>
> 1. You can use a combination of static-key and pv-ops - see for example
> steal_account_process_time()

Okay, I was kind of already heading in this direction. The static key
I am using now would probably stay put.

> 2. You can use callee-saved pv-ops.
>
> The latter might anyhow be necessary since, IIUC, you change a very hot
> path. So you may want have a look on the assembly code of free_pcp_prepar=
e()
> (or at least its code-size) before and after your changes. If they are to=
o
> big, a callee-saved function might be necessary.

I'll have to take a look. I will spend the next couple days
familiarizing myself with the pv-ops infrastructure.

