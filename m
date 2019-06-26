Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5608C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 17:14:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B9862177B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 17:14:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="m+cjANgM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B9862177B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2919E6B0006; Wed, 26 Jun 2019 13:14:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 242868E0003; Wed, 26 Jun 2019 13:14:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 158E98E0002; Wed, 26 Jun 2019 13:14:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D5E2B6B0006
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 13:14:22 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id q14so2177438pff.8
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 10:14:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=iZ0b+/lUcP9zaaMexkUlQdqvpgfJZAjpzHawxGUTRJg=;
        b=GlvyOo8/RObamSSkJnE0R35qTbcW+IPZljNCM4zDpNIRfchSTv2r2NEZYdZ4NLofZ5
         LSHev/tngEfOfSxnhydh5RNcY9qTaj2OnmTu4fQt1IED+xPJOcZMP1Tuk80A9qnD8mvi
         5Xiy61D9iXVfrm0igGaC6kPVIxnTdo1h7jU5WdvyM2/OKG1Ubiq9PW4yml7mJ2w6g+Ig
         3s/jbf/hjrw72NT900aPXq1xNv0N/nXasJ9YsIPc5W5JrR1Z9vV5FhiTIaxMH2xjEIox
         VMbHDT0Odo9TrYn6e2P/dcY8aywz5pD2LUSzLaaAd4Vb+NbhPseh5+ZVP4SCHjDBFYDC
         seYA==
X-Gm-Message-State: APjAAAXC6c4m8v+Bj4B/Ti7mkWf98YnjN3k2alDAeZW/Lwmc0fkQHLH7
	f4o5QTLiXfECW2AKSYF08Q1CPGUGbQ+cOgEXzXQspZPfBrYRwYtLH552CW6g5sTIY8YHTFwRZcH
	eyMs5uDOkDO7kAhysspmcX55Re0FiKY5dQVK5iJYxrC2A+LD6WMxKUqcxhav6VqGb4Q==
X-Received: by 2002:a17:902:8d91:: with SMTP id v17mr6589579plo.91.1561569262427;
        Wed, 26 Jun 2019 10:14:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdVMh62OIDZjo41HtFcynm9quUclq2e2fgdnvUfIyOn9MFy8QK+XpiaWq3WMuh3WJ145ju
X-Received: by 2002:a17:902:8d91:: with SMTP id v17mr6589483plo.91.1561569261403;
        Wed, 26 Jun 2019 10:14:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561569261; cv=none;
        d=google.com; s=arc-20160816;
        b=TprkaJZrUlWFBcHg7tw9JizlnAk1Iu9JAyUATjo9OUPqdT1mWkxrN5Lqeep/hiPZPF
         h8jARx7qFXiZAuXFNC+WsZzEaK+ip7VFdyTFZUF0x3jRePrjLfwPMdVge/cI9/ZhuYfH
         7GI6irCWOnqWBYrpMf5dzAjsQFR9YN/qcRAcozUCBWISyOB5vmZimUqU0r44DYgDxvKT
         nbS0BtsH9EzkK4aL2RIWJ87n0seH1x2G2mIB+J+4z/Z6mOySu2WyqlIQIRmiLZrm+JHA
         Zglzv6qgaolcxno4dPmPJusva8ZlAxN9fysXm4xtHjYao6UgF2sFc6Q0/2AZMWENvQxj
         j0eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=iZ0b+/lUcP9zaaMexkUlQdqvpgfJZAjpzHawxGUTRJg=;
        b=AEBsVXN2nGy3Hk3DxLK2ZPccx+YbTZcZ+raQnvCMXQaVn0PhO0Ti4tJ+LW985tkqyX
         3hAFniPJ1D6o5JHtzglpgvrxc+2cxv+qDEnPncDLZOKW8CYWpKprz4oCjYUsY5T1Ykem
         SUcTOMKfnZ5wL9JuwNgCiHfi5cDMqxX4MTt/SAGTbgLyzAihErNo2yh2ZrHBLXixGIDr
         MP/WxDA+lgF9ii9vZpuF0rafto4VHjSvmJRhs+IUaBMRcI9UvgQMexlJSxXk717qCNb/
         4FoOTQqQetCWGlCkc4Vr2QT6jWqSqgekqTwhhXab+I5OrYeF3dCv4h65LPy2KlJtwUgU
         stOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=m+cjANgM;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x3si15518091pgr.22.2019.06.26.10.14.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 10:14:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=m+cjANgM;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 96FC52183F
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 17:14:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561569260;
	bh=IPJPblNMOSzpc4o8oUY4BwkKbCN4n/1QDhjL5Fv7ep4=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=m+cjANgMOKu9iYPrmIEkq3ir867euC6fdTabpwRWKebv6Efr6ulwc+y5QuteG304H
	 /QfQMK0QGFunEvQafok0oocQabttk4YNZs1+7OtTC3sL8zB6GFf2+B0BddImiFJWF2
	 BYP7KtBDmXc/06DRGFT2JJ7dkt9otFAQzEU2u14U=
Received: by mail-wr1-f51.google.com with SMTP id f9so3596092wre.12
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 10:14:20 -0700 (PDT)
X-Received: by 2002:adf:f28a:: with SMTP id k10mr4711752wro.343.1561569259059;
 Wed, 26 Jun 2019 10:14:19 -0700 (PDT)
MIME-Version: 1.0
References: <20190501211217.5039-1-yu-cheng.yu@intel.com> <20190502111003.GO3567@e103592.cambridge.arm.com>
In-Reply-To: <20190502111003.GO3567@e103592.cambridge.arm.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 26 Jun 2019 10:14:07 -0700
X-Gmail-Original-Message-ID: <CALCETrVZCzh+KFCF6ijuf4QEPn=R2gJ8FHLpyFd=n+pNOMMMjA@mail.gmail.com>
Message-ID: <CALCETrVZCzh+KFCF6ijuf4QEPn=R2gJ8FHLpyFd=n+pNOMMMjA@mail.gmail.com>
Subject: Re: [PATCH] binfmt_elf: Extract .note.gnu.property from an ELF file
To: Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, X86 ML <x86@kernel.org>, 
	"H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
	LKML <linux-kernel@vger.kernel.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, 
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, 
	Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, 
	Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, 
	Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, 
	Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, 
	Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Szabolcs Nagy <szabolcs.nagy@arm.com>, 
	libc-alpha <libc-alpha@sourceware.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 2, 2019 at 4:10 AM Dave Martin <Dave.Martin@arm.com> wrote:
>
> On Wed, May 01, 2019 at 02:12:17PM -0700, Yu-cheng Yu wrote:
> > An ELF file's .note.gnu.property indicates features the executable file
> > can support.  For example, the property GNU_PROPERTY_X86_FEATURE_1_AND
> > indicates the file supports GNU_PROPERTY_X86_FEATURE_1_IBT and/or
> > GNU_PROPERTY_X86_FEATURE_1_SHSTK.
> >
> > This patch was part of the Control-flow Enforcement series; the original
> > patch is here: https://lkml.org/lkml/2018/11/20/205.  Dave Martin responded
> > that ARM recently introduced new features to NT_GNU_PROPERTY_TYPE_0 with
> > properties closely modelled on GNU_PROPERTY_X86_FEATURE_1_AND, and it is
> > logical to split out the generic part.  Here it is.
> >
> > With this patch, if an arch needs to setup features from ELF properties,
> > it needs CONFIG_ARCH_USE_GNU_PROPERTY to be set, and a specific
> > arch_setup_property().
> >
> > For example, for X86_64:
> >
> > int arch_setup_property(void *ehdr, void *phdr, struct file *f, bool inter)
> > {
> >       int r;
> >       uint32_t property;
> >
> >       r = get_gnu_property(ehdr, phdr, f, GNU_PROPERTY_X86_FEATURE_1_AND,
> >                            &property);
> >       ...
> > }
>
> Thanks, this is timely for me.  I should be able to build the needed
> arm64 support pretty quickly around this now.
>
> [Cc'ing libc-alpha for the elf.h question -- see (2)]
>
>
> A couple of questions before I look in more detail:
>
> 1) Can we rely on PT_GNU_PROPERTY being present in the phdrs to describe
> the NT_GNU_PROPERTY_TYPE_0 note?  If so, we can avoid trying to parse
> irrelevant PT_NOTE segments.
>
>
> 2) Are there standard types for things like the program property header?
> If not, can we add something in elf.h?  We should try to coordinate with
> libc on that.  Something like
>

Where did PT_GNU_PROPERTY come from?  Are there actual docs for it?
Can someone here tell us what the actual semantics of this new ELF
thingy are?  From some searching, it seems like it's kind of an ELF
note but kind of not.  An actual description would be fantastic.

Also, I don't think there's any actual requirement that the upstream
kernel recognize existing CET-enabled RHEL 8 binaries as being
CET-enabled.  I tend to think that RHEL 8 jumped the gun here.  While
the upstream kernel should make some reasonble effort to make sure
that RHEL 8 binaries will continue to run, I don't see why we need to
go out of our way to keep the full set of mitigations available for
binaries that were developed against a non-upstream kernel.

In fact, if we handle the legacy bitmap differently from RHEL 8, we
may *have* to make sure that we don't recognize existing RHEL 8
binaries as CET-enabled.

Sigh.

