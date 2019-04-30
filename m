Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19970C46470
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 11:05:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBF9021707
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 11:05:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="t98F86tk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBF9021707
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63D2F6B0272; Tue, 30 Apr 2019 07:05:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5EE3B6B0274; Tue, 30 Apr 2019 07:05:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B6AF6B0275; Tue, 30 Apr 2019 07:05:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id F17A46B0272
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 07:05:54 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id r7so15812862wrc.14
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 04:05:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=hcjAClggzePqeJJtXogSOe2XblmZfTT3PJ7ZOWIVOqU=;
        b=hCLfWrGvePgy7XvqrvqI7D1ixDHlpZ4wOV9LRPlnHftJaPaOdix7bTnQB2mURWGi1O
         Fj2g/hczf/HtDEoZi3T90aRCOvhogTSMIZfBRUHAQF1NF2Yj7je+unTAO8SpL3RmsqCA
         D2Ie8a7xvCrCRnTsJ6cf+a0kFvlWOzsFUPYPhTVWXBhbjwktal3GzQrdH7Z/ZT3eKu8R
         JwEIq9Bxj8N7Eq02XdRnkXOC35OPCjNHBj+Ix5qd5qW330PYe3LBCeH8z/cd5HWL1CqJ
         IeGJNQnNNXJCDIBlGUPnZjGXNTAYM7Z/DZSIoAQEL6r0/b8ufnznivvOG//3cnyygJxv
         tJVQ==
X-Gm-Message-State: APjAAAVy1wFfPgacrRiv0D7ByzGBRMkQOv0KuznMvKIm7fror2CCvnd1
	3p7PTkCDOXZmjpr3D6z6ZlKqhlVzmOFVvtS+ryoAeUC5Fxs7qPAnk1YdsWr71AnmCrAtWs0aeNb
	fhEAgNsco/5J2GNqCFZz/epSqtH18oindLP7SoiwvkjjV+xHAA46FxzJahCYyjw8=
X-Received: by 2002:adf:f749:: with SMTP id z9mr28826158wrp.218.1556622354393;
        Tue, 30 Apr 2019 04:05:54 -0700 (PDT)
X-Received: by 2002:adf:f749:: with SMTP id z9mr28826077wrp.218.1556622353407;
        Tue, 30 Apr 2019 04:05:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556622353; cv=none;
        d=google.com; s=arc-20160816;
        b=wurMkuH2GTlXKriNpMcyyJIoWHPA85jWBtY0AexZWj73Uk5SQeApNX83fyGW3ONDR6
         mKA8TowUqaf7LIuHhCUbqHdhh2JFkc3z/jwb0dv4cAaAK1hlKBnAMMKH9rChZy/CXyVu
         hNocKQ3DVbaIO3Xfk9ssuz2J0U+1qnjkmbJdOOzn17r4qNw/fhzIa4lN/VN/dxXuc5qI
         VAQNuuMCImS5civq+Jgd5zerWaJHgp4rt+l0vHusxDU1nQby2M7flbAGVsUic+EFuFFr
         dFGBPSuRo8gRbtuRrk05LdettD4fYULCrT6yjKKEZOqDnOWgWViWgD64coqWCqTEtGA5
         T3kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=hcjAClggzePqeJJtXogSOe2XblmZfTT3PJ7ZOWIVOqU=;
        b=EFeUsDYCR06u47cE7oH7O+ns43S5apomXJx5vQLIVK9GPCpicUUw7hlgIvLVuPenf5
         pgFo35FX7OewSfSnlm1S5sKgeEY8PCM2/z2uFtfkkMX2HCcSnCgJ/RtMu1SufNEWLCK0
         gzLNvEwzg20e7CfX3y48w6DpA208UuAa1hXlffL/xkja8ZlWPMJu6Mhad+cJC4w4hz+v
         Z9GTXHVqpO9HZ+89imLGDqL23O6PR+49+4UvC6Jv7b4NZGWm9Tj5xDIRpiVvlk8JETtM
         VI/RYEwy5h96HC+wVYm7neySPYNo8FD0fCKcg1ClIQYG4V7okUPeTxGJNn40FxauGoWG
         8/yw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=t98F86tk;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b13sor314506wrj.21.2019.04.30.04.05.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 04:05:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=t98F86tk;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=hcjAClggzePqeJJtXogSOe2XblmZfTT3PJ7ZOWIVOqU=;
        b=t98F86tkS7nDT8aNYRRoUWLg5OJwxhtOdcoSs/BsTtn9OgzzITqrjV4cmLJ98Mwb1P
         Mqw3Dky/HvlbeumYpqCqDtokl2IbheHHUnKfUpXQ0vQd6X+E1+vsNWuApgGiz1Ij6D6i
         +9xEmITSRyeCwSFy9q9E4JB3oCgGLdH24ITrmedONPahTcgCy77/DWS8CyWArsuDWL/w
         owESCNvAj/CWa7Sb/6wh4ChvjV4oU0P3zh91GnzAIafx5K0sRIqzIGcixj4Gxq4j97rE
         k2XyJDVliGcsNDXJHNAcFA+7Vw9dqdqI3dOV3G6HyXz1P5JqwFoCvCTftErm8e2FhbSr
         rxxA==
X-Google-Smtp-Source: APXvYqx47jP/dkWfwfM3K6Jq6/BSx7pleW6oIHBiVt9pYJlp3l08JXsCge/13B3lJoEXdct7iMOKyg==
X-Received: by 2002:adf:e288:: with SMTP id v8mr8583758wri.7.1556622353105;
        Tue, 30 Apr 2019 04:05:53 -0700 (PDT)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id b11sm4059486wmh.29.2019.04.30.04.05.50
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 Apr 2019 04:05:52 -0700 (PDT)
Date: Tue, 30 Apr 2019 13:05:49 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Alexandre Chartre <alexandre.chartre@oracle.com>,
	Borislav Petkov <bp@alien8.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Jonathan Adams <jwadams@google.com>,
	Kees Cook <keescook@chromium.org>, Paul Turner <pjt@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	X86 ML <x86@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system call
 isolation
Message-ID: <20190430110549.GA119957@gmail.com>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com>
 <20190426083144.GA126896@gmail.com>
 <20190426095802.GA35515@gmail.com>
 <CALCETrV3xZdaMn_MQ5V5nORJbcAeMmpc=gq1=M9cmC_=tKVL3A@mail.gmail.com>
 <20190427084752.GA99668@gmail.com>
 <20190427104615.GA55518@gmail.com>
 <CALCETrUn_86VAd8FGacJ169xcWE6XQngAMMhvgd1Aa6ZxhGhtA@mail.gmail.com>
 <20190430050336.GA92357@gmail.com>
 <20190430093857.GO2623@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190430093857.GO2623@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, Apr 30, 2019 at 07:03:37AM +0200, Ingo Molnar wrote:
> > So the question IMHO isn't whether it's "valid C", because we already 
> > have the Linux kernel's own C syntax variant and are enforcing it with 
> > varying degrees of success.
> 
> I'm not getting into the whole 'safe' fight here; but you're under
> selling things. We don't have a C syntax, we have a full blown C
> lanugeage variant.
> 
> The 'Kernel C' that we write is very much not 'ANSI/ISO C' anymore in a
> fair number of places. And if I can get my way, we'll only diverge
> further from the standard.

Yeah, but I think it would be fair to say that random style variations 
aside, in the kernel we still allow about 95%+ of 'sensible C'.

> And this is quite separate from us using every GCC extention under the 
> sun; which of course also doesn't help. It mostly has to do with us 
> treating C as a portable assembler and the C people not wanting to 
> commit to sensible things because they think C is a high-level 
> language.

Indeed, and also because there's arguably somewhat of a "if the spec 
allows it then performance first, common-sense semantics second" mindset. 
Which is an understandable social dynamic, as compiler developers tend to 
distinguish themselves via the optimizations they've authored.

Anyway, the main point I tried to make is that I think we'd still be able 
to allow 95%+ of "sensible C" even if executed in a "safe runtime", and 
we'd still be able to build and run without such strong runtime type 
enforcement, i.e. get kernel code close to what we have today, minus a 
handful of optimizations and data structures. (But the performance costs 
even in that case are nonzero - I'm not sugarcoating it.)

( Plus even that isn't a fully secure solution with deterministic 
  outcomes, due to parallelism and data races. )

Thanks,

	Ingo

