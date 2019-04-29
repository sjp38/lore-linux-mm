Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A03E5C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 14:22:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 504672084B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 14:22:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="nSUn3qna"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 504672084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC7676B0007; Mon, 29 Apr 2019 10:22:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C76BE6B0008; Mon, 29 Apr 2019 10:22:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B90A76B000A; Mon, 29 Apr 2019 10:22:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 80DD66B0007
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 10:22:22 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i14so7305830pfd.10
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 07:22:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Q2RFfAyrf9RFoM43ktNZPcHmGWgFL8fnuov2nkBPWS8=;
        b=kcyQze/FmWWEpLaCFw7dzyYLqkDVnA+DLPnGlA+TDEnAGvMAZWng0/oREQ0CyBpWMB
         DcOJj4NR4TD9FvXZqNyMLz1cAG1+RpbH16BW7bxGsyP+ypkiKBV4+hNCWmid4y+7V4kn
         /MznZj04Jzunp3I79m+Ujx8guQ9zUtBWSfaU7H+Xv/UaV9ciTUPNjqU+4pwSNyWiYZUM
         GERBNK/iwizqnOxNc2G00aPjCwA2xAJ5ngN6WFmLEgCY6fbv2ggplU6YGUU3L0ArV3qq
         LgTPi2yETQbNREgLuT1aBHhPQgA819+jkG3Xbb/EudsPiHYH7NqgESxYAkuPzNcwogZA
         9keQ==
X-Gm-Message-State: APjAAAX4cWiuWRrz1gVMaVGi8kk3k4GGTvHwefHSL7XCw5WCseOCpOir
	WOfvsg6Nmgh77poy2RlsURA+h+V0O17aXgz99yChUy5/fl7bzJCtGCTa2/kWboTsOqzYc1FMv4g
	AEqv3kemtIPOcMLT6owtcf5pdvzoXydL2ea8wEUw6HiNNHbUM02FQLCzwmjoPIcb+RA==
X-Received: by 2002:a63:c54a:: with SMTP id g10mr35247772pgd.71.1556547742039;
        Mon, 29 Apr 2019 07:22:22 -0700 (PDT)
X-Received: by 2002:a63:c54a:: with SMTP id g10mr35247710pgd.71.1556547741173;
        Mon, 29 Apr 2019 07:22:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556547741; cv=none;
        d=google.com; s=arc-20160816;
        b=JT2U4Z3GPny/x+N6YAmjW8FUF/NtAJ2kAXg9Hdk4bf5IqLNHO6snimfk0/wQ7PgUvY
         z9HrAdghUm8a3/W05rw2fgVS3+mWiKsxEoo+HYfFuljA/wDy+euXJ5IkOOxep0YkCzQ0
         axzr3Hum9Lf1xCBAo8pq1p4FtlVGeaEiuS+rmrqgs6L0ySGdB5TL73P5WZ11u5pJ0m5R
         gX3GogyTUPqrBPpz338O0tslI+7Gg7cinBUOMvfUaTkmcoDE7imeHEqyC4uMoXIpeIz8
         BLAc3tHal5lVRD2TvSZax1UmKxm+3Z5ufMaYvLcWxEh+CS3admbeuYYlkSLyq9bF8rJJ
         tMVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Q2RFfAyrf9RFoM43ktNZPcHmGWgFL8fnuov2nkBPWS8=;
        b=tqkcbgHJemJZH4I0wsejBQYvKse8v8j19i1Up6zZ/zyKxdGYY5IbNQQqv+7kndYQOb
         GD+Fg2D4sWOqPekRlxX3PrlBH9Y+OaJxeoAWRc9V7seyYLJ95fBb4RkRXdpJuROQ+rjO
         xmS42fDkDYLzy01sr6YgbmpgpIisXQCSWSGPj4UPthTT9DbPleEDXYKBK/4ePZjSpSoj
         wzYp0EQWqt5wea+67KKYdDz9vdNp/i20dT3hi99fMg7aOosDfpf/CwGM/6SqC/2Py7eD
         lUJep66pGQfzNC3vEDtw+gKyE2qVB/ldncDuk1Jan3M2o1DwUTRJIG05LX9qAfelwRqE
         lnIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nSUn3qna;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p66sor37025184pfp.35.2019.04.29.07.22.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Apr 2019 07:22:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nSUn3qna;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Q2RFfAyrf9RFoM43ktNZPcHmGWgFL8fnuov2nkBPWS8=;
        b=nSUn3qnawAssSs6MaxKqsGt7m2rQuwz8iuV7UDRO4XwagTQcUwQLKJChDfpo2Y42Xk
         dLm04wkPLwmDDcGlfi33gt+mgTjEgazJ0pWoNgMCBCgvVwv5SPNGO+R0wOTcgS/YyTDI
         MMCTRBCf6Y5X7Op946XZIErDxOVRLAN1uJUSs6b8aMjiipEdz924r1uFPAVVEONFnBC1
         eRjcEW3uL1UMy4VUvg8gNA4Pg7nsW7DCRDuZC0iLpBAnBGkKHCDzwyf3Uq04LayvwlmL
         Hgpedt4edzE9KmfV/TNfyjqaPwOmLbR2KI1O6u2H+6Cx6SK8d3Pu0MrHeMD38gdpjP27
         JeSg==
X-Google-Smtp-Source: APXvYqyjdyjRGlJ4AtmMgCZd/Nm8Zu8D+p70gtT5fOtGOIKXAcrI3uZOPLT4eOOdJOYGY3S3MZtVzM6xnMJJE/TXbvw=
X-Received: by 2002:a62:51c5:: with SMTP id f188mr24041707pfb.239.1556547740003;
 Mon, 29 Apr 2019 07:22:20 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com> <44ad2d0c55dbad449edac23ae46d151a04102a1d.1553093421.git.andreyknvl@google.com>
 <20190322114357.GC13384@arrakis.emea.arm.com> <CAAeHK+xE-ywfpVHRhBJVGiqOe0+BYW9awUa10ZP4P6Ggc8nxMg@mail.gmail.com>
 <20190328141934.38960af0@gandalf.local.home> <20190329103039.GA44339@arrakis.emea.arm.com>
 <CAAeHK+xe-zWn8WpCxUxBB2tXL8oiLkshkPi1J3Ly87mACaA4-A@mail.gmail.com> <20190426141742.GB54863@arrakis.emea.arm.com>
In-Reply-To: <20190426141742.GB54863@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 29 Apr 2019 16:22:08 +0200
Message-ID: <CAAeHK+xx_kB_U_ws8eUHOE8SkhGCcERNVcJoaMYbP9TGb+q2tg@mail.gmail.com>
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

On Fri, Apr 26, 2019 at 4:17 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Tue, Apr 02, 2019 at 02:47:34PM +0200, Andrey Konovalov wrote:
> > On Fri, Mar 29, 2019 at 11:30 AM Catalin Marinas
> > <catalin.marinas@arm.com> wrote:
> > > On Thu, Mar 28, 2019 at 02:19:34PM -0400, Steven Rostedt wrote:
> > > > On Thu, 28 Mar 2019 19:10:07 +0100
> > > > Andrey Konovalov <andreyknvl@google.com> wrote:
> > > >
> > > > > > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > > > > > ---
> > > > > > >  ipc/shm.c      | 2 ++
> > > > > > >  mm/madvise.c   | 2 ++
> > > > > > >  mm/mempolicy.c | 5 +++++
> > > > > > >  mm/migrate.c   | 1 +
> > > > > > >  mm/mincore.c   | 2 ++
> > > > > > >  mm/mlock.c     | 5 +++++
> > > > > > >  mm/mmap.c      | 7 +++++++
> > > > > > >  mm/mprotect.c  | 1 +
> > > > > > >  mm/mremap.c    | 2 ++
> > > > > > >  mm/msync.c     | 2 ++
> > > > > > >  10 files changed, 29 insertions(+)
> > > > > >
> > > > > > I wonder whether it's better to keep these as wrappers in the arm64
> > > > > > code.
> > > > >
> > > > > I don't think I understand what you propose, could you elaborate?
> > > >
> > > > I believe Catalin is saying that instead of placing things like:
> > > >
> > > > @@ -1593,6 +1593,7 @@ SYSCALL_DEFINE3(shmat, int, shmid, char __user *, shmaddr, int, shmflg)
> > > >       unsigned long ret;
> > > >       long err;
> > > >
> > > > +     shmaddr = untagged_addr(shmaddr);
> > > >
> > > > To instead have the shmaddr set to the untagged_addr() before calling
> > > > the system call, and passing the untagged addr to the system call, as
> > > > that goes through the arm64 architecture specific code first.
> > >
> > > Indeed. For example, we already have a SYSCALL_DEFINE6(mmap, ...) in
> > > arch/arm64/kernel/sys.c, just add the untagging there. We could do
> > > something similar for the other syscalls. I don't mind doing this in the
> > > generic code but if it's only needed for arm64, I'd rather keep the
> > > generic changes to a minimum.
> >
> > Do I understand correctly, that I'll need to add ksys_ wrappers for
> > each of the memory syscalls, and then redefine them in
> > arch/arm64/kernel/sys.c with arm64_ prefix, like it is done for the
> > personality syscall right now? This will require generic changes as
> > well.
>
> Yes. My aim is to keep the number of untagged_addr() calls in the
> generic code to a minimum (rather than just keeping the generic code
> changes small).

OK, will do in v14 (despite it still being unclear whether we should
do untagging here or not).

>
> --
> Catalin

