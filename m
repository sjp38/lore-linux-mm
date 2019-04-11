Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35FE5C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 16:40:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B703B20693
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 16:40:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="SoNczOUv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B703B20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 157B46B026B; Thu, 11 Apr 2019 12:40:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E0126B026C; Thu, 11 Apr 2019 12:40:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE9B56B026D; Thu, 11 Apr 2019 12:40:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B365E6B026B
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 12:40:26 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id u2so4725157pgi.10
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 09:40:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=kRgyn84oa29XmD7BiIgkjrSoRGcUByl/xukvkl6TYAI=;
        b=BAd9/5NlbK/ivld28sZ0eJobyKljQVzUSg6lQeNcFAqZPK/mbQa0w/r76LQk8lvAN8
         LLdwzulZiYmnZJ1u5Rmr7zLI0Z5qUOTgAyWCOZ3W62WqSzhVITVPQy0I+9DslpHefyfN
         DJ8Vy6MNvCb+vvhlrRsR2snXLAY6ctbyy4KYJmr5LZBfwoqsNm+eilu2w1MGjHjIqXvb
         P4sg6Wd3lpqcr2G00QxfCEZvYkj8ROfUVaIdOOzt1c42YP708RqeoUS7R5OUJobBWjra
         h8eFhAQRAXgM8vOM120t/Qt7vosG3XyEJGc1Sy+8xyA4zmjnth9+WiDuHWu8qAtotqBn
         qsyw==
X-Gm-Message-State: APjAAAW7xj2I8JO4o0ScS8JeNZ/RFpR2DO4HeOTL5uWxvPpVAn3A16uA
	t/33vUugh41ih/z6l9olclWcIMi2CbBOdKnev8hLON+UmDnTJC+MQgcbY+kUIByBAciCWVN1QWf
	MjBljfj27rXGUkfBqniQpGBdTgpt/rzHmopYN2OQmGqMC6vL5kVb5KqAz3EuCJokc5w==
X-Received: by 2002:a17:902:e110:: with SMTP id cc16mr51683657plb.147.1555000826097;
        Thu, 11 Apr 2019 09:40:26 -0700 (PDT)
X-Received: by 2002:a17:902:e110:: with SMTP id cc16mr51683547plb.147.1555000824989;
        Thu, 11 Apr 2019 09:40:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555000824; cv=none;
        d=google.com; s=arc-20160816;
        b=xXb8HYhGGOY8xdMiG0Ew+luXufLAaDrSHOUu6JDYQoWt2F53mgl0Ldkt8CWEqvKylX
         PYiZsAYO7NHrpSaUZCIrZ+H1inQJHgPKqKoq4TBEASdv2r2Uwu/dd+m97kWWgKKIV0S+
         e4HfFFmBqisY37ODzmJSSVODecJdcYzsmqIB+CzgNkVGdrhFJzZgI+l1Uf73mnWmyTMR
         LxbHh8qDQePkxwdnVHebkZ3tZK5qH79OJAX2UPGb19d4iNW0092YY5a5rzOMmt26vaSe
         gqJ7jfDzPRrRgijZZrWGjTiKY7UxGGUIeGprSA6WNhS47Vg5RTsKw7alhre0KzGHbflD
         Wchw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=kRgyn84oa29XmD7BiIgkjrSoRGcUByl/xukvkl6TYAI=;
        b=PXQULqhJGYWRtveKGCZSm+lAdJMdokMjHpHkGmYxsW5MeT8swQ0YxeQU5z46bFkJb3
         Q5AHhgVZ4ezeMwFlV/iJwDqSjmlbT/UYSbhW+SOHb/IhkRYe//E32vPI9eQg7ocx3Aek
         LzsST6yy3HyAIhkcmiYpxsux1msC13z1Wa1nhVC45JcMrWY75ECp9H1hg/ckVs3oaQW6
         8dVmgkakApBAcgeHO2WdMKRXrZoLaPr/Es0+sUtIogJ9I9pGFWsxqXkDqyJAqV/BAJGQ
         xnNMDlfhBOMoo8g0IuAKUkVmZZOwheuZMI5iPCZDnBj1bEvTeoiktw6MgxVfxglBEF5S
         8wSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SoNczOUv;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n25sor36319320pgv.11.2019.04.11.09.40.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 09:40:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SoNczOUv;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=kRgyn84oa29XmD7BiIgkjrSoRGcUByl/xukvkl6TYAI=;
        b=SoNczOUvZP35dy1JqqbI48ANljHHieaupBksGGPCN9782NN4FNvPZAMOeymTzYuYJl
         KiHd8ACn2sggNQkz4cP9Y0UlLatijbbSrAMLoUQOyy7ZC740Yt1HM9hRU7VK+riBtyWt
         SpCvuvoxNhHY6NYST5pv7zkv5F6hTtUq5hBXFpQgntYKCUYQ1oGyMotbJ50fPfaHyJp9
         4guhGuIJTEMB6yJ9EnbQqZmUChheWvHCl+MSGrHIRNeXz3E65krd7ZXz0Jx3mawxlStn
         iLNK8lGgq1HcHDIXEwJ65fH//h8oODA1f+R97yN1b91gq/KkfVLVEa0rOgeJHpJA4l8O
         mwfA==
X-Google-Smtp-Source: APXvYqwealWxNqfe0UwP6cRYXZUxVOaGNLqMHlBL7SnCGa5or89aJ7/sNi4RivH+ohBpurt1TGx6k8oqHitkrhMhtoM=
X-Received: by 2002:a63:cf0d:: with SMTP id j13mr47949382pgg.34.1555000824096;
 Thu, 11 Apr 2019 09:40:24 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com> <44ad2d0c55dbad449edac23ae46d151a04102a1d.1553093421.git.andreyknvl@google.com>
 <20190322114357.GC13384@arrakis.emea.arm.com> <CAAeHK+xE-ywfpVHRhBJVGiqOe0+BYW9awUa10ZP4P6Ggc8nxMg@mail.gmail.com>
 <20190328141934.38960af0@gandalf.local.home> <20190329103039.GA44339@arrakis.emea.arm.com>
 <CAAeHK+xe-zWn8WpCxUxBB2tXL8oiLkshkPi1J3Ly87mACaA4-A@mail.gmail.com>
In-Reply-To: <CAAeHK+xe-zWn8WpCxUxBB2tXL8oiLkshkPi1J3Ly87mACaA4-A@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 11 Apr 2019 18:40:12 +0200
Message-ID: <CAAeHK+zzMukPL3SXJOqZkCfdT4UaVi=7sxrRfuktZt4DodgO7g@mail.gmail.com>
Subject: Re: [PATCH v13 04/20] mm, arm64: untag user pointers passed to memory syscalls
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Kees Cook <keescook@chromium.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Eric Dumazet <edumazet@google.com>, 
	"David S. Miller" <davem@davemloft.net>, Alexei Starovoitov <ast@kernel.org>, 
	Daniel Borkmann <daniel@iogearbox.net>, Peter Zijlstra <peterz@infradead.org>, 
	Arnaldo Carvalho de Melo <acme@kernel.org>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 2, 2019 at 2:47 PM Andrey Konovalov <andreyknvl@google.com> wrote:
>
> On Fri, Mar 29, 2019 at 11:30 AM Catalin Marinas
> <catalin.marinas@arm.com> wrote:
> >
> > (I trimmed down the cc list a bit since it's always bouncing)
> >
> > On Thu, Mar 28, 2019 at 02:19:34PM -0400, Steven Rostedt wrote:
> > > On Thu, 28 Mar 2019 19:10:07 +0100
> > > Andrey Konovalov <andreyknvl@google.com> wrote:
> > >
> > > > > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > > > > ---
> > > > > >  ipc/shm.c      | 2 ++
> > > > > >  mm/madvise.c   | 2 ++
> > > > > >  mm/mempolicy.c | 5 +++++
> > > > > >  mm/migrate.c   | 1 +
> > > > > >  mm/mincore.c   | 2 ++
> > > > > >  mm/mlock.c     | 5 +++++
> > > > > >  mm/mmap.c      | 7 +++++++
> > > > > >  mm/mprotect.c  | 1 +
> > > > > >  mm/mremap.c    | 2 ++
> > > > > >  mm/msync.c     | 2 ++
> > > > > >  10 files changed, 29 insertions(+)
> > > > >
> > > > > I wonder whether it's better to keep these as wrappers in the arm64
> > > > > code.
> > > >
> > > > I don't think I understand what you propose, could you elaborate?
> > >
> > > I believe Catalin is saying that instead of placing things like:
> > >
> > > @@ -1593,6 +1593,7 @@ SYSCALL_DEFINE3(shmat, int, shmid, char __user *, shmaddr, int, shmflg)
> > >       unsigned long ret;
> > >       long err;
> > >
> > > +     shmaddr = untagged_addr(shmaddr);
> > >
> > > To instead have the shmaddr set to the untagged_addr() before calling
> > > the system call, and passing the untagged addr to the system call, as
> > > that goes through the arm64 architecture specific code first.
> >
> > Indeed. For example, we already have a SYSCALL_DEFINE6(mmap, ...) in
> > arch/arm64/kernel/sys.c, just add the untagging there. We could do
> > something similar for the other syscalls. I don't mind doing this in the
> > generic code but if it's only needed for arm64, I'd rather keep the
> > generic changes to a minimum.
>
> Do I understand correctly, that I'll need to add ksys_ wrappers for
> each of the memory syscalls, and then redefine them in
> arch/arm64/kernel/sys.c with arm64_ prefix, like it is done for the
> personality syscall right now? This will require generic changes as
> well.

ping

>
> >
> > (I had a hack overriding __SC_CAST to do this automatically for pointer
> > arguments but this wouldn't work on mmap() and friends as the argument
> > is unsigned long)
> >
> > --
> > Catalin

