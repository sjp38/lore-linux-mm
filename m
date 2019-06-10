Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78436C4321A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 19:56:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B0FA20859
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 19:56:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="uLzHkUDA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B0FA20859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 868EC6B026A; Mon, 10 Jun 2019 15:56:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 818FF6B026C; Mon, 10 Jun 2019 15:56:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B9BB6B026D; Mon, 10 Jun 2019 15:56:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F1386B026A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:56:04 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b24so6298442plz.20
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 12:56:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=811lIuMO3QaODXd3K9NvSgTVL+VZs2KoWd/ysaH2IQc=;
        b=Qi5+0lqT9VoLtYTd2Fro+b0+8Rx5+0mPC94lOGEwv7Wy2iTA6mqUJVXXkBiUgdCnQJ
         BnTFmEkRyNuIHZL97aQwRf2efkhM3tYxX7KTiYElL/M8QJ0Jpo8tE3H/vVJO+aKroPkF
         L+Xa1u/deWwSHthqmHZ+V2qyND5qjGW6uR9GWmvDoHkuQqAl/jzgwvhzryo2xZ2FVF2B
         WsobNVP1wl8zcuhFadc7EUlZfKv3Ysk6qLHzgUGFXW54ry+koeKJ9DLu0VAjak9Rpnv+
         RAHjuZy4NcwH/+5fohoAZ1uHbRx/eKQuuqp4mBmv19qAAdRycVjOdCToR4RfKnhJ8zzD
         eemw==
X-Gm-Message-State: APjAAAWZa/BstJ04vt7tTATn2O0+AiUWkJ0IFzeASnMQIVnbMHDwhTF4
	tYy+kYP6xKaBANjzuVR7m0dEp+etRsJULApcTDwP1quoKtFlQLpFO1P45GYOiBZBITrYqvVKQQp
	EZZ0nmb0MAoXMUTvo7v2AnUG135Fy26JMOE0VxIql3ZA8VJQs6S7oX0KDBhTh4KOJtA==
X-Received: by 2002:a17:902:7591:: with SMTP id j17mr72503515pll.200.1560196563739;
        Mon, 10 Jun 2019 12:56:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzseGX0bVc0H/+uAFQYhyHIFoX23ec6DMaiKGTyskSdXPDjJgqb/TBoVVSSLd+eZ1Vdi9Wr
X-Received: by 2002:a17:902:7591:: with SMTP id j17mr72503462pll.200.1560196562888;
        Mon, 10 Jun 2019 12:56:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560196562; cv=none;
        d=google.com; s=arc-20160816;
        b=0Q2GWPqemovTkqgQkrX8DIsDHEhm4mS2jKycpUxBaKSrlyMzIerZbPd/rT/EdJiqts
         ZR4ui8SVBLB4McONyV9mc6nPWCiHW6BfOLxiUw/1Zdv+JBlTr1E7WYuv3/x/yqA6k4gF
         0RWe9Qo6sdsW4qMu56z1neuF++JdRy1NT2rUqBpqJ9mNm89USSNoBY6jKAXcVNgxXPsq
         iJ/80VmjZZqY30CzUP4K6SA1GC3Ns/HAkbfWQVKh+j7gdA/vArLgp8Wu8MhlvMHMDlJI
         v/IZ8qaWn3CKul8YxoQvd0l0apcZI8g2CNWfmyqulwrqC9UsE/gPVmo86AyaRDCiCq9z
         xe6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=811lIuMO3QaODXd3K9NvSgTVL+VZs2KoWd/ysaH2IQc=;
        b=hvRXThXb2RCDVoTDUUVErYkx7hFsdFUlQuXTOJVmlIEzeHVwl+T5s8ZJd2HWd3ogkR
         dVhB+Y3DdZVICe+paa/SInZ1XqfWA9M8uo+4+cPhnrY3S5ll1grgGnKJIMKHNPjaEV9L
         hKai4olM4lKWRa4VQ1nvRWhvOrA/4s5ELPn//jBlEFeNEfnVCydlDhZHDcDv4/8MJ8uV
         ZmxtCY5lcXtGXJo7ATpiWZcP+vMa80tWBJK6zBj2/jI4SIVJWmpfkvDJWUc71chGuGxk
         GRuIGwVFXzXvSm1q1nAEuE+Eo8b7TonxU2jZxUHAmTAzu8GZleJxj0oAOjINJySxqCqN
         zhiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=uLzHkUDA;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d3si3841491pgc.299.2019.06.10.12.56.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 12:56:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=uLzHkUDA;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f44.google.com (mail-wm1-f44.google.com [209.85.128.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 22F6B21744
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 19:56:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560196562;
	bh=BSrEs7k4Eaj+qfKqbXB7x6RBjqYairyQB7xlNqEmonI=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=uLzHkUDAQ8jOsA8YXnkz0O3Qklab8tzkEtYYWwVgKRQkiQKzSqsdLapdzrorKdIKK
	 n6Eo4HwM27qI73UXdMC+Vo7aJo27Dlu5OTlBwsHayFksgsHw2rZwNM92HHc08myrfM
	 frywWd5NERvhfQ373QnY3PfJ7m2L8vxY6KRo3fOE=
Received: by mail-wm1-f44.google.com with SMTP id 207so558448wma.1
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 12:56:02 -0700 (PDT)
X-Received: by 2002:a7b:cd84:: with SMTP id y4mr14984047wmj.79.1560196560570;
 Mon, 10 Jun 2019 12:56:00 -0700 (PDT)
MIME-Version: 1.0
References: <20190606200926.4029-1-yu-cheng.yu@intel.com> <20190606200926.4029-4-yu-cheng.yu@intel.com>
 <20190607080832.GT3419@hirez.programming.kicks-ass.net> <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
 <20190607174336.GM3436@hirez.programming.kicks-ass.net> <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net> <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
 <25281DB3-FCE4-40C2-BADB-B3B05C5F8DD3@amacapital.net> <e26f7d09376740a5f7e8360fac4805488b2c0a4f.camel@intel.com>
 <3f19582d-78b1-5849-ffd0-53e8ca747c0d@intel.com> <5aa98999b1343f34828414b74261201886ec4591.camel@intel.com>
 <0665416d-9999-b394-df17-f2a5e1408130@intel.com>
In-Reply-To: <0665416d-9999-b394-df17-f2a5e1408130@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 10 Jun 2019 12:55:48 -0700
X-Gmail-Original-Message-ID: <CALCETrVzgkhu=kjF4U5MEc+TJmsDJf8pVgnoPH5F4gTdsDF4rQ@mail.gmail.com>
Message-ID: <CALCETrVzgkhu=kjF4U5MEc+TJmsDJf8pVgnoPH5F4gTdsDF4rQ@mail.gmail.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup function
To: Dave Hansen <dave.hansen@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, Peter Zijlstra <peterz@infradead.org>, X86 ML <x86@kernel.org>, 
	"H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
	LKML <linux-kernel@vger.kernel.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, 
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>, 
	Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, 
	Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, 
	Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, 
	Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>, 
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Dave Martin <Dave.Martin@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 12:52 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 6/10/19 12:38 PM, Yu-cheng Yu wrote:
> >>> When an application starts, its highest stack address is determined.
> >>> It uses that as the maximum the bitmap needs to cover.
> >> Huh, I didn't think we ran code from the stack. ;)
> >>
> >> Especially given the way that we implemented the new 5-level-paging
> >> address space, I don't think that expecting code to be below the stack
> >> is a good universal expectation.
> > Yes, you make a good point.  However, allowing the application manage the bitmap
> > is the most efficient and flexible.  If the loader finds a legacy lib is beyond
> > the bitmap can cover, it can deal with the problem by moving the lib to a lower
> > address; or re-allocate the bitmap.
>
> How could the loader reallocate the bitmap and coordinate with other
> users of the bitmap?
>
> > If the loader cannot allocate a big bitmap to cover all 5-level
> > address space (the bitmap will be large), it can put all legacy lib's
> > at lower address.  We cannot do these easily in the kernel.
>
> This is actually an argument to do it in the kernel.  The kernel can
> always allocate the virtual space however it wants, no matter how large.
>  If we hide the bitmap behind a kernel API then we can put it at high
> 5-level user addresses because we also don't have to worry about the
> high bits confusing userspace.
>

That's a fairly compelling argument.

The bitmap is one bit per page, right?  So it's smaller than the
address space by a factor of 8*2^12 == 2^15.  This means that, if we
ever get full 64-bit linear addresses reserved entirely for userspace
(which could happen if my perennial request to Intel to split user and
kernel addresses completely happens), then we'll need 2^48 bytes for
the bitmap, which simply does not fit in the address space of a legacy
application.

