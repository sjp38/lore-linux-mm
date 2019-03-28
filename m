Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D12EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 18:19:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24A432173C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 18:19:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24A432173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 645016B026B; Thu, 28 Mar 2019 14:19:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F3866B026C; Thu, 28 Mar 2019 14:19:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 495316B026D; Thu, 28 Mar 2019 14:19:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 06DAA6B026B
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:19:42 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a72so16915145pfj.19
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:19:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=v2Pk8vwVJEKevmVbVwbjgZdGoINUNiAQiZlY83dEjAU=;
        b=MWKWJoZsS/9uz8NLZ9jA7AmoLQn6UG8+iGwzz0u/jN5EpfM990gotGP+R1bIvgp5Rn
         OGT8HbUqcf88L4kOPhaagHSXaKp8CGlQ9vAXiKC2Gwb5tE31pPm+T+pnoBT5SIZD8kJN
         6ty7CBvtKc9DZcUlFN6zHgwW4tBxbhrgJBrJBOWP22jZlla5xkx+jUoTwQ0uJxTm4D6T
         ZqHUcHQhbMIJluh/FMINFHyXE5PFYlm/aIMEoi5HKonWI7blkttVT8NtVurcGadsJ/DE
         Bmu7FXX8eijrbU/s9gvQFiham7xcYoomAeom+6QrQMbZVgfwjLUN9yzbkG0yIzrE5PAv
         2taA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=sarb=r7=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=saRB=R7=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAUZ2rJUznHegCc9RYX3QefF/Ax2U4ciM8mpfJyHO3DlxRjJYK4Z
	pY3arhFM5H4TtuVggIWjA0yf3FthV9PYMKpySxqplGVnwt7f4XvAQSd3IEL0lPFB1Ql8WbpLwHS
	i/TzT2Hz/WJpKgeRpvmQr+FiZDcQEyB88yhDD6mgG+UF1ZwxDysWJsFpWK5zN1rg=
X-Received: by 2002:a17:902:788d:: with SMTP id q13mr45309968pll.154.1553797181701;
        Thu, 28 Mar 2019 11:19:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmjCNGVvglIYneUOL9T3gyqsr9qUYvnscP3vDfWeVZ5CPo0P+naLh9UoCiKA04kspoFCh6
X-Received: by 2002:a17:902:788d:: with SMTP id q13mr45309915pll.154.1553797180968;
        Thu, 28 Mar 2019 11:19:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553797180; cv=none;
        d=google.com; s=arc-20160816;
        b=GqhiGsdyUxAihcwkmNjkpVOmJ5IaFahb52GvxM2RBNwnCOE1OazGcd2aBVEzrTI9/j
         EaL6jqZeXYEaaBwC47y0c0JJ1/30tnQKUF+5YXgPy5pV89shevUVNNuD99Ezcx2pA1Ya
         ZJglKgGBSt1Qrjvdz8ymvI2ipmomLJnN8Q/iqEAdx4ZVnhPtNv+4qoNcs5xUYlJMaWaB
         OCuQujFNVvcsBbdeW+U5WqJbY41brGgvoo/gTEPymUwn1OCjC3S02lw46msDvhHAOaXH
         gRIcjhbvCJNQQJ8QNupGgakgxuOoEtJC3j0Z29NnYsfmi3qtcL8ujb6PmHcxFudiDJ9j
         yHeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=v2Pk8vwVJEKevmVbVwbjgZdGoINUNiAQiZlY83dEjAU=;
        b=se7W6D6FD2561BKBt0ApMrVH8cFxHo5Coimw/WWy2FX7L2hrUxsBAIQ4VOeVfAUGM7
         YaPsC3WELazZ11WDoCVd7NVolZoPFROMwu84i+PKXaRpLaMIkFz8YD9s66Z7d7l/xCb+
         KnpoJk+NGvgaxXGNRTt3/iBYsdIsMaiha4+TFs/H32sGM/cCJgVeOU6M1Dfl4JjhsBpC
         /naBSzIaBirnANfk9v83TczDZ29Vz7XlNXZWe9yaSX4z4OgtA98MXOSRF7Th64K21TwL
         KuDQRp6ID+Nxr5JF2H9NA7/PiJ2qLnAoZVcCmufNpAKLMlbzL+UZ3WsE74ODG4qKQTsD
         JoSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=sarb=r7=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=saRB=R7=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x15si1020201pgi.524.2019.03.28.11.19.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 11:19:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=sarb=r7=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=sarb=r7=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=saRB=R7=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 61DFB2082F;
	Thu, 28 Mar 2019 18:19:36 +0000 (UTC)
Date: Thu, 28 Mar 2019 14:19:34 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy
 <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, Kate Stewart
 <kstewart@linuxfoundation.org>, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>,
 Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov"
 <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Vincenzo
 Frascino <vincenzo.frascino@arm.com>, Eric Dumazet <edumazet@google.com>,
 "David S. Miller" <davem@davemloft.net>, Alexei Starovoitov
 <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Ingo Molnar
 <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho
 de Melo <acme@kernel.org>, Alex Deucher <alexander.deucher@amd.com>,
 Christian =?UTF-8?B?S8O2bmln?= <christian.koenig@amd.com>, "David
 (ChunMing) Zhou" <David1.Zhou@amd.com>, Yishai Hadas
 <yishaih@mellanox.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Jens
 Wiklander <jens.wiklander@linaro.org>, Alex Williamson
 <alex.williamson@redhat.com>, Linux ARM
 <linux-arm-kernel@lists.infradead.org>, Linux Memory Management List
 <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, netdev
 <netdev@vger.kernel.org>, bpf <bpf@vger.kernel.org>,
 amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
 linux-rdma@vger.kernel.org, linux-media@vger.kernel.org,
 kvm@vger.kernel.org, "open list:KERNEL SELFTEST FRAMEWORK"
 <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>,
 Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley
 <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Chintan Pandya <cpandya@codeaurora.org>, Luc Van Oostenryck
 <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, Kevin
 Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v13 04/20] mm, arm64: untag user pointers passed to
 memory syscalls
Message-ID: <20190328141934.38960af0@gandalf.local.home>
In-Reply-To: <CAAeHK+xE-ywfpVHRhBJVGiqOe0+BYW9awUa10ZP4P6Ggc8nxMg@mail.gmail.com>
References: <cover.1553093420.git.andreyknvl@google.com>
	<44ad2d0c55dbad449edac23ae46d151a04102a1d.1553093421.git.andreyknvl@google.com>
	<20190322114357.GC13384@arrakis.emea.arm.com>
	<CAAeHK+xE-ywfpVHRhBJVGiqOe0+BYW9awUa10ZP4P6Ggc8nxMg@mail.gmail.com>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Mar 2019 19:10:07 +0100
Andrey Konovalov <andreyknvl@google.com> wrote:

> > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > ---
> > >  ipc/shm.c      | 2 ++
> > >  mm/madvise.c   | 2 ++
> > >  mm/mempolicy.c | 5 +++++
> > >  mm/migrate.c   | 1 +
> > >  mm/mincore.c   | 2 ++
> > >  mm/mlock.c     | 5 +++++
> > >  mm/mmap.c      | 7 +++++++
> > >  mm/mprotect.c  | 1 +
> > >  mm/mremap.c    | 2 ++
> > >  mm/msync.c     | 2 ++
> > >  10 files changed, 29 insertions(+)  
> >
> > I wonder whether it's better to keep these as wrappers in the arm64
> > code.  
> 
> I don't think I understand what you propose, could you elaborate?

I believe Catalin is saying that instead of placing things like:

@@ -1593,6 +1593,7 @@ SYSCALL_DEFINE3(shmat, int, shmid, char __user *, shmaddr, int, shmflg)
 	unsigned long ret;
 	long err;
 
+	shmaddr = untagged_addr(shmaddr);

To instead have the shmaddr set to the untagged_addr() before calling
the system call, and passing the untagged addr to the system call, as
that goes through the arm64 architecture specific code first.

-- Steve

