Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C127EC04AA6
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 18:43:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8242721670
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 18:43:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ild4RLQx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8242721670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1551C6B0003; Mon, 29 Apr 2019 14:43:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1057E6B0005; Mon, 29 Apr 2019 14:43:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 01AB06B0007; Mon, 29 Apr 2019 14:43:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B95CC6B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 14:43:34 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i14so7732644pfd.10
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 11:43:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=14Q54mxaAFYbQZRoOXRQB3siUXrELeCo5kBqUg6u0YI=;
        b=m+EnX9RuTqdCDN2adx90XeYzql4qzMlPpDEv8wJCidxp1N8B5kJw9Nd5ijqHyCWJkU
         RFdSq+zkMYBpvKxrTzC/sebVTUdPHRAq/cxyYSOzw81U0MPr8oiKFyK10BJnUzCCDgDm
         x6+0RCwk4KzviMv8wp6wC0MBzNZ72+3kk31gtorSe0VTUkvhBHfvQfA4ZYmFnieRtMwQ
         ei9tdpASahyhXoSs5ydTfJk0N0mwYWyCoqOhoDQWMlRenydZLHoE4rqvGSXTp5zO2hv1
         H/dkicxGgF8DPHH2CHTI+F3PhRZ6530w5hIeaYif+UT6vVUS3Gt7ZI267f1RtDhYCtku
         0X+g==
X-Gm-Message-State: APjAAAW6YHqWkLM8AFL0CeHeVckqfPotEeAb1k+kJ16xKRA8Y9ZzZIWT
	F0NN7eWjvcRv71Vth2Y7GtfScbhzi9rZsAOMU8R9A5Xk7JQCzGj7Bz6CWozBqDlGyjE33tDC7Am
	Vg3/Tu1sgeGKL69zAYP4wHcmolcB/cxf9kuJCHHdY3pO4Gcj6MHL+s7cUnrGZ6DrTqw==
X-Received: by 2002:a63:d408:: with SMTP id a8mr28259831pgh.184.1556563414412;
        Mon, 29 Apr 2019 11:43:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxy+LKWyBg1QDDjOr+K0DJIVlE+NLRuERWKEPoQnOfP46NTa238hMhn+ifMwCrRsx4Tn1nj
X-Received: by 2002:a63:d408:: with SMTP id a8mr28259744pgh.184.1556563413706;
        Mon, 29 Apr 2019 11:43:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556563413; cv=none;
        d=google.com; s=arc-20160816;
        b=VjesFqltb6XIAdM550uxZt5JGGlE/nBL0oW/if7s19bA9hCWo/rzyEwSDj8LUWN8EO
         mcByGuDpMjT5FPA5Z9emQzYEiSqwrgeyOUk8Gh+hoI1juJSHC+LDNDNuX6eDj2Kksudk
         nOu/YbgQAW+yVMeHcyudf6RzJi9ZpxF3UviVzcEvxbkLhWwdn0MUFTucU9cDD2AwLYAB
         BskZaPNIquXTifDZ/ecB2I4Nea25prkEPg6mAmQdDmR8A3srbzkzaRe4RKY7wYI8CFvK
         AJZVNwHSHkgHwTh70GaqYX4xQdPrFZbO2mwEcdqUjC5OCOp4RKJ0F0M15MElMymbADRS
         zTNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=14Q54mxaAFYbQZRoOXRQB3siUXrELeCo5kBqUg6u0YI=;
        b=dm/fY20W3Wa99DEmWWtxjoTlZoLNvim5chj2xSO36tVZ3bE7Hq6xCQubNn7XtE130O
         WinVf4zhIlffPo/bTEzFh0NB3F2NTdz5u8iz2DuloNkX08ZjGgkrIDiIYd+YJ6+IyJoD
         HRHlypWUpZmm91DMRBvkH8HQoT38sMXVP7HDfNM4dER54eb/rtHsVYZ2nXfebiZTPL7B
         SA1w8QKf1+JlULB2VHYj9j3/x1nSrwUomyOtt5rjLpPMx4SzfX4So80Z8sIKM8yCQfO9
         gyHCi/QEGLxe19gZ7sisBYoWxmOP+lZEwfly6u1F3eLcSt2/2AcVQ4V8nM4mgPhS9hOk
         IWow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Ild4RLQx;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f9si34234448pgu.31.2019.04.29.11.43.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 11:43:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Ild4RLQx;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f48.google.com (mail-wm1-f48.google.com [209.85.128.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1053421841
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 18:43:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556563413;
	bh=TYbYR6xdiAT33fFeBDJqUP8mpRliL4fUyIr32o3R6Ao=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=Ild4RLQx9rtlOvTMTH/a2NOZwv2KhSkHHDSs0/ztbX9IjEWNeAvPTIQTDmmrTUpaP
	 P/Jlymb7EAxnHAX7dIW4dLamRL85KAqgyYJcADejzz0al8WIhPxUz7QWocmNVaz1IN
	 d+Gx835qgvYw2xFHS1KphzxoLeAN69ShA+e9NJA0=
Received: by mail-wm1-f48.google.com with SMTP id h18so592021wml.1
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 11:43:33 -0700 (PDT)
X-Received: by 2002:a7b:c844:: with SMTP id c4mr331867wml.108.1556563411667;
 Mon, 29 Apr 2019 11:43:31 -0700 (PDT)
MIME-Version: 1.0
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com> <20190426083144.GA126896@gmail.com>
 <20190426095802.GA35515@gmail.com> <CALCETrV3xZdaMn_MQ5V5nORJbcAeMmpc=gq1=M9cmC_=tKVL3A@mail.gmail.com>
 <20190427084752.GA99668@gmail.com> <20190427104615.GA55518@gmail.com> <alpine.LRH.2.21.1904300425200.20645@namei.org>
In-Reply-To: <alpine.LRH.2.21.1904300425200.20645@namei.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 29 Apr 2019 11:43:20 -0700
X-Gmail-Original-Message-ID: <CALCETrX0T0_Cn8UivmRwtRZ8N3joT_MfQom+TKLZ2aqxqm7dYA@mail.gmail.com>
Message-ID: <CALCETrX0T0_Cn8UivmRwtRZ8N3joT_MfQom+TKLZ2aqxqm7dYA@mail.gmail.com>
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system call isolation
To: James Morris <jmorris@namei.org>
Cc: Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, 
	Mike Rapoport <rppt@linux.ibm.com>, LKML <linux-kernel@vger.kernel.org>, 
	Alexandre Chartre <alexandre.chartre@oracle.com>, Borislav Petkov <bp@alien8.de>, 
	Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, 
	Ingo Molnar <mingo@redhat.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, 
	Jonathan Adams <jwadams@google.com>, Kees Cook <keescook@chromium.org>, Paul Turner <pjt@google.com>, 
	Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>, 
	LSM List <linux-security-module@vger.kernel.org>, X86 ML <x86@kernel.org>, 
	Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, 
	Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 29, 2019 at 11:27 AM James Morris <jmorris@namei.org> wrote:
>
> On Sat, 27 Apr 2019, Ingo Molnar wrote:
>
> >  - A C language runtime that is a subset of current C syntax and
> >    semantics used in the kernel, and which doesn't allow access outside
> >    of existing objects and thus creates a strictly enforced separation
> >    between memory used for data, and memory used for code and control
> >    flow.
>
> Might be better to start with Rust.
>

I think that Rust would be the clear winner as measured by how fun it sounds :)

