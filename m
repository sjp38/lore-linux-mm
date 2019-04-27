Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52D76C43219
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 10:46:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F09ED2087C
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 10:46:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iHWAeykZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F09ED2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 785CF6B0006; Sat, 27 Apr 2019 06:46:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70D406B0008; Sat, 27 Apr 2019 06:46:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D4786B000A; Sat, 27 Apr 2019 06:46:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 103396B0006
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 06:46:21 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v5so6312846wrn.6
        for <linux-mm@kvack.org>; Sat, 27 Apr 2019 03:46:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=xPSO7oJ3TTHplWc4133d26O3LVrGQFrQK7ot/N5WKb8=;
        b=P60MNJf4rzNjZL3tsrYtrywFOEZxFonbeQEx2MFUY8qoekl3nkEQlGPQx6lwE5pw/z
         nEXDMj0h5x3m0n3Mx4BxsHfwtTw+cIjorU7h/asBdys0ujMTEevtKwSniVfx+4hfslWz
         NVCfzqT/+4xDcm2AVpKKXdl0vvva0wS9TfbTUOkx85aPWgLNWeuL4eHQxD1a0NuGNQQe
         DOdUvgkWg//U4h9zDwGSPFXQAzxMsSkV7x1An2ejE/P6jUPO+TUPHjs0pGSWAp3GH42g
         8bco7kv8+CTE44h+ziVQGbdEAe6H9/la4z2Q4DZZ2nMMiQNAhwZnx8dd6p79kQtmSs8k
         6s0Q==
X-Gm-Message-State: APjAAAVXVilSieSEoe3bmddjivQJ85txiUonOKjJ0xbdc8Xjg7RkMLx7
	a5zjK8keEiiQk87lEHUUEYznNiKxKrNYseQ5wJDGjk1ZEFvh59ZY0Zv9IhzxPLQSzvuyF/ynjTy
	DG1K9H58ImuYza9wI7LLSKVymyk8cl1m/K21cGLG4IlbtLKVBzeyBP64hKk0rhrU=
X-Received: by 2002:a5d:4eca:: with SMTP id s10mr17379577wrv.319.1556361980536;
        Sat, 27 Apr 2019 03:46:20 -0700 (PDT)
X-Received: by 2002:a5d:4eca:: with SMTP id s10mr17379540wrv.319.1556361979542;
        Sat, 27 Apr 2019 03:46:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556361979; cv=none;
        d=google.com; s=arc-20160816;
        b=YgRV6KoVQZF17mEWFm26yHqRqkXtQfid3oo6te1G670AdnVxwkcVu6vslGdJSq1QH2
         CQ49Y5AolJSSmZ99saCg5V6WFas0CmJoVRKi2rZrueo++3trXCC6mBCk3PeCvjIVmZph
         aq9Ii4+mYVTfO6Ieo7BNYUSILhy6aFYeF+kLDD10bSEB0iO3eRz3P/q2/ftSE0HGaoJu
         hhQvEDsYMS7bSvhGyytULkZUFClzzc819yUt4ZKDDJb/FhmL3L2i7maZxzDlXcehAlwt
         ZK2KyfIb46q0IzDGxYl4yzbaT+3bWmrzhpxsLqvRlPac5cURwnDtOHKvqtUuFlUS0yFQ
         uUGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=xPSO7oJ3TTHplWc4133d26O3LVrGQFrQK7ot/N5WKb8=;
        b=I8lDEfWWAk5fRJbjOQPtxG/J979pYXCYH9xn769ufszC4kKB4r6oTq3FbXDRyVakXT
         crY3iBJHlPqGwkz1VmgtYg+YQRYDdJYu1sAU826Ga4ZvrZTBtPu11aI1qyO89l+9Y39x
         cQgTRcRz3e73YOfbkUTmCuSqtOAHW96pGOZTMno7bBj9AsNn9nuttVQmwKvmk5BAMVyz
         VLAY3EGZiEbJ9ZG7qzt2J5xpUmsfxEU/VAvF/T3+1UGmvlvqlluFZyTwYZbr1uRBlh1H
         juiU/SRihhoFjT0XM8olcLxny+x9IZ3ynubfpp0y1vbTmWG0caxJUDLPc9QQwPShc8Fy
         hSHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iHWAeykZ;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v7sor16755439wro.43.2019.04.27.03.46.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 27 Apr 2019 03:46:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iHWAeykZ;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=xPSO7oJ3TTHplWc4133d26O3LVrGQFrQK7ot/N5WKb8=;
        b=iHWAeykZHCFDxFy3680Aunv30P6sD1QDGJ2K2UX7UeCJZs4+FMT5RWJb7Hog4/R5r9
         dm464UwSg9xMQ+y/Z5uVB2BGznF0SE9F8Kg3VXIWarHzUo2Zv1Wvbj/ZAtT1g6jIh9b7
         y/3PLs3P3keba5yFj4miN1eRmesniXQJIk4eHjBfjfQoYfFitAejpaMGYBnli3jGX1lc
         6U94wTq2CKBAYQ2kqNH2xUHuguqjvm5FdcCaujFsNqEHr1Y6JHrRclOlTD4kgUR+ogfH
         UKNk7HQQDKIYlryRPWZXYC93srNNuZYpAYiUqhrBOsdQ05mCl/nJZnj/D+45V25B6rVL
         o/RQ==
X-Google-Smtp-Source: APXvYqxY/dnkrLpW/gF+xVDmMuF7QvDiCj7GAGdhfgtGKCgk/7ONprlc+TDqzgFDBPe+eG8Nb+V+zw==
X-Received: by 2002:a5d:6b46:: with SMTP id x6mr32608036wrw.313.1556361978927;
        Sat, 27 Apr 2019 03:46:18 -0700 (PDT)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id x14sm9639485wmi.32.2019.04.27.03.46.17
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 27 Apr 2019 03:46:18 -0700 (PDT)
Date: Sat, 27 Apr 2019 12:46:15 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>, LKML <linux-kernel@vger.kernel.org>,
	Alexandre Chartre <alexandre.chartre@oracle.com>,
	Borislav Petkov <bp@alien8.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Jonathan Adams <jwadams@google.com>,
	Kees Cook <keescook@chromium.org>, Paul Turner <pjt@google.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	X86 ML <x86@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system call
 isolation
Message-ID: <20190427104615.GA55518@gmail.com>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com>
 <20190426083144.GA126896@gmail.com>
 <20190426095802.GA35515@gmail.com>
 <CALCETrV3xZdaMn_MQ5V5nORJbcAeMmpc=gq1=M9cmC_=tKVL3A@mail.gmail.com>
 <20190427084752.GA99668@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190427084752.GA99668@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* Ingo Molnar <mingo@kernel.org> wrote:

> * Andy Lutomirski <luto@kernel.org> wrote:
> 
> > > And no, I'm not arguing for Java or C#, but I am arguing for a saner
> > > version of C.
> > 
> > IMO three are three credible choices:
> > 
> > 1. C with fairly strong CFI protection. Grsecurity has this (supposedly 
> > — there’s a distinct lack of source code available), and clang is 
> > gradually working on it.
> > 
> > 2. A safe language for parts of the kernel, e.g. drivers and maybe 
> > eventually filesystems.  Rust is probably the only credible candidate. 
> > Actually creating a decent Rust wrapper around the core kernel 
> > facilities would be quite a bit of work.  Things like sysfs would be 
> > interesting in Rust, since AFAIK few or even no drivers actually get 
> > the locking fully correct.  This means that naive users of the API 
> > cannot port directly to safe Rust, because all the races won't compile
> > :)
> > 
> > 3. A sandbox for parts of the kernel, e.g. drivers.  The obvious 
> > candidates are eBPF and WASM.
> > 
> > #2 will give very good performance.  #3 gives potentially stronger
> > protection against a sandboxed component corrupting the kernel overall, 
> > but it gives much weaker protection against a sandboxed component 
> > corrupting itself.
> > 
> > In an ideal world, we could do #2 *and* #3.  Drivers could, for 
> > example, be written in a language like Rust, compiled to WASM, and run 
> > in the kernel.
> 
> So why not go for #1, which would still outperform #2/#3, right? Do we 
> know what it would take, roughly, and how the runtime overhead looks 
> like?

BTW., CFI protection is in essence a compiler (or hardware) technique to 
detect stack frame or function pointer corruption after the fact.

So I'm wondering whether there's a 4th choice as well, which avoids 
control flow corruption *before* it happens:

 - A C language runtime that is a subset of current C syntax and 
   semantics used in the kernel, and which doesn't allow access outside 
   of existing objects and thus creates a strictly enforced separation 
   between memory used for data, and memory used for code and control 
   flow.

 - This would involve, at minimum:

    - tracking every type and object and its inherent length and valid 
      access patterns, and never losing track of its type.

    - being a lot more organized about initialization, i.e. no 
      uninitialized variables/fields.

    - being a lot more strict about type conversions and pointers in 
      general.

    - ... and a metric ton of other details.

 - If such a runtime could co-exist without big complications with 
   regular C kernel code then we could convert particular pieces of C 
   code into this safe-C runtime step by step, and would also allow the 
   compilation of a piece of code as regular C, or into the safe runtime.

 - If a particular function can be formally proven to be safe, it can be 
   compiled as C - otherwise it would be compiled as safe-C.

 - ... or something like this.

The advantage would be: data corruption could never be triggered by code 
itself, if the compiler and runtime is correct. Return addresses and 
stacks wouldn't have to be 'hardened' or 'checked', because they'd never 
be corrupted in the first place. WX memory wouldn't be an issue as kernel 
code could never jump into generated shell code or ROP gadgets.

The disadvantage: the overhead of managing this, and any loss of 
flexibility on the kernel programming side.

Does this make sense, and if yes, does such a project exist already?
(And no, I don't mean Java or C#.)

Or would we in essence end up with a Java runtime, with C syntax?

Thanks,

	Ingo

