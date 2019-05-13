Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7BC6C46470
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:02:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7792D2168B
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 16:02:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="QnhBLyrl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7792D2168B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 154A46B0280; Mon, 13 May 2019 12:02:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 106E06B0282; Mon, 13 May 2019 12:02:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F10646B0284; Mon, 13 May 2019 12:02:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B91766B0280
	for <linux-mm@kvack.org>; Mon, 13 May 2019 12:02:47 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id k22so9835507pfg.18
        for <linux-mm@kvack.org>; Mon, 13 May 2019 09:02:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=eCJScE0b+VNTPBqsRt3H1dcVApPbPwSgCSFEuoANhc8=;
        b=Y55b7DiaHOdJnMHhtd/c9qJdqikzPE94sXDJQDWYdwsfdHnjDncS7myAJHNT9ZIZSO
         Om4RJAYaeuCGpHd8yvUYBfexT4kx3cXhcbEMD/ICVDsDMzs0N5zrtvXgnMyDiJWX/nol
         Ijgd6DJTHi9LtfU2p/rM/RX1erKP/fEz9FPyvVbSbYXESlp5OGi+4Ut3OH5A5Lct7o8j
         ZbZXhoJ+IbiJtKejNDhTUyU+Wm3J/BnwI8pLiagg/OZy7MmODlictYM6XgcYE9pZK1U5
         Pw33tB38DpCkslcHm/XEaFF5j4HocnVEtd69RF4QD2Pjqg9VTdhgQPfGhNbYTiW0K1jL
         jIbw==
X-Gm-Message-State: APjAAAXpHTGR74tAunhDTNRlMsPEpO0U2xxp/KN5e5DNa7vl+0lrKdpB
	Xpph7SbF6VoMDLvOhAq0+3/G0Ki+SNzzJb+g7ZqduabdsglzX5fLPp9ytKE+mkC62WFHkX+Dui9
	ZefMZ1nWlB9edGLRp+NIYCF0PJJ4kHl7zr1T7C5LzfvWlLawLUBE+6Iz9JpYGfebZQw==
X-Received: by 2002:a62:4595:: with SMTP id n21mr34777447pfi.79.1557763367459;
        Mon, 13 May 2019 09:02:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPYOxXxzfitGhiWQsDBbjPu5mmPqR47fusm4yuoa9DKMYaPo4yKkPplVPWv9mL7XaPqKfL
X-Received: by 2002:a62:4595:: with SMTP id n21mr34777316pfi.79.1557763366635;
        Mon, 13 May 2019 09:02:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557763366; cv=none;
        d=google.com; s=arc-20160816;
        b=K6oD4RgmvexmYHkCiESu2u+Quzs0L+H4NzERXmkVSxn+OqAOkuhoD59RPbKVlh98Jc
         wa1CYFV00nAhYKHsFfWiJh5Ts6xq/1Pqs3JVbA5EMahzI1CgfDKGUNcg6ixP3juMPpFp
         by/ccp9ckvZpGrQvt6m62N3KDi33M77/OsaUvcdZrKxaX9pHySp1Q5ci5SgHJtKalqWs
         PH6wpHJ1fj5nFaDGCXFZR2lAc7Rc5RyQCbXhpPSOEde1BxzcNfMXTNM4ftkseZ5BFk48
         TjTvtI5zTro15zViX+LxsbzNPTwfFehzodXlEdjZvuREme8PeTwO6gUn7LU+/nrmG6/S
         WC6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=eCJScE0b+VNTPBqsRt3H1dcVApPbPwSgCSFEuoANhc8=;
        b=btsDXjjepyk0OWFBpwLuhpNKUj3/3YOlqVW0cvQEhs2CZ8SupF7n+XTyQmy4vvO6ZZ
         Xlve5DgpXJ6eDjF7B9LoVE1cKk3V+UZzeDJ6mRiNXXlN/ftC/F8AVhtlUCUt/b4vb3xm
         PwPpcujPK/xQWrwCm1XGJH/ydEttaRZ9nnvZxm0Ub6hvuT8gMC3HrS98m6WGuox0nBo+
         23TP+mj4mBRKR0KYTxR3WICsGgWBtKdwaMtUcchrxpBFX+t7rO8L4R3wUc+hTzVYNVfg
         3LCJ1Ue+EsMQ8jyzd7nbH/6f8RNtLsDBm1LptwBjgBlRlre+q3nsxO/N7eepwiPr5Xd6
         W1Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=QnhBLyrl;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 3si17679359pgt.305.2019.05.13.09.02.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 09:02:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=QnhBLyrl;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f50.google.com (mail-wr1-f50.google.com [209.85.221.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1731E21881
	for <linux-mm@kvack.org>; Mon, 13 May 2019 16:02:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557763366;
	bh=beoZx4frclCxoXSfTxDXkTuSz0AY0hIAwe1mG3lYD+0=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=QnhBLyrlFAFdFMdYGjrxtpZTRix4ohkczb2rqgQsWALhgFd6D7tiD8w3qEuQjKa4t
	 6gACJ1mq+rjkrjjgv78C9L1ngGrELfh60U9CNvxeFR0bF4yIiw25vABiO2v6YO8nwh
	 2BOKdf6lHrzPUcK3M8mxJ2O4+dZiPBseqIuRUnko=
Received: by mail-wr1-f50.google.com with SMTP id w12so15940309wrp.2
        for <linux-mm@kvack.org>; Mon, 13 May 2019 09:02:46 -0700 (PDT)
X-Received: by 2002:adf:fb4a:: with SMTP id c10mr17614362wrs.309.1557763364695;
 Mon, 13 May 2019 09:02:44 -0700 (PDT)
MIME-Version: 1.0
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com> <1557758315-12667-25-git-send-email-alexandre.chartre@oracle.com>
In-Reply-To: <1557758315-12667-25-git-send-email-alexandre.chartre@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 13 May 2019 09:02:33 -0700
X-Gmail-Original-Message-ID: <CALCETrXADiujgE6HJ95P_da5OyB05Z5CqR028da50aCUHv4Agg@mail.gmail.com>
Message-ID: <CALCETrXADiujgE6HJ95P_da5OyB05Z5CqR028da50aCUHv4Agg@mail.gmail.com>
Subject: Re: [RFC KVM 24/27] kvm/isolation: KVM page fault handler
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Andrew Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, kvm list <kvm@vger.kernel.org>, 
	X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, jan.setjeeilers@oracle.com, 
	Liran Alon <liran.alon@oracle.com>, Jonathan Adams <jwadams@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 7:39 AM Alexandre Chartre
<alexandre.chartre@oracle.com> wrote:
>
> The KVM page fault handler handles page fault occurring while using
> the KVM address space by switching to the kernel address space and
> retrying the access (except if the fault occurs while switching
> to the kernel address space). Processing of page faults occurring
> while using the kernel address space is unchanged.
>
> Page fault log is cleared when creating a vm so that page fault
> information doesn't persist when qemu is stopped and restarted.

Are you saying that a page fault will just exit isolation?  This
completely defeats most of the security, right?  Sure, it still helps
with side channels, but not with actual software bugs.

