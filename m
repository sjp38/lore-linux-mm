Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BB5FC46460
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 02:07:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 110DA21537
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 02:07:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="AWYLnYQX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 110DA21537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A16786B0003; Mon, 13 May 2019 22:07:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A0796B0005; Mon, 13 May 2019 22:07:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 819706B0007; Mon, 13 May 2019 22:07:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 461DD6B0003
	for <linux-mm@kvack.org>; Mon, 13 May 2019 22:07:51 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id b24so10434838pgh.11
        for <linux-mm@kvack.org>; Mon, 13 May 2019 19:07:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=HS+u+zhrivtPGNBbCaE1swQKUpAdxESip9XcNifCPoc=;
        b=RDevuh21tIrdZqe4okXkhY7/adEQZRh0zdQTDL3or5Xbb+q9uRoemNnUdLL4LuKFYj
         BfVfvOs5PDudFp9HxJuZ/r5fDPdmyJwssw0finNS2Hg3+pYvuX+pun9IgQdNUCr+yGDG
         5OWsceadj5iU7gBIE8zaDyQIJiecm2uVljE0OZVkojWyQu+DiDi/V+x3/WFzv1hBfK3D
         /29u/gosEueBXTAWhIUQBC4vv5Q/09pwxnjhoLA+Ld+7xX2nYn2pmhSSoNPhrmbRrXFx
         wMpuS8DZBR5Ip49R9C1WLisjXhK4BtrxfRpT+6Dykn4zbiSwUjrHNrI6diFglwvRLNCf
         83Cw==
X-Gm-Message-State: APjAAAUAMqhbttNlbs/qXx3WetMtuKv1Sj4JEcWfDPYkMHMgqV+prSJT
	ragXZZqofplMC88JQ9ncjXraKQ2xND/zbIU/ZpsEx1fLYJYFxKk48KUWTtxthQfUmCw2bGK43/h
	sYYGU1W/QOt82wx4Req7T7agn5xMfIN3/d3ClVRf7+Jz/Cz8dpi18mC9sk2NR1hydhQ==
X-Received: by 2002:a63:1055:: with SMTP id 21mr34779707pgq.200.1557799670874;
        Mon, 13 May 2019 19:07:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwufpqAp2p818a4Ot25WTHbO5Rr+x0+mjecRx6wTgpFkLVRx3x9YQwB5NWHJpoG3dzV/oQW
X-Received: by 2002:a63:1055:: with SMTP id 21mr34779653pgq.200.1557799669938;
        Mon, 13 May 2019 19:07:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557799669; cv=none;
        d=google.com; s=arc-20160816;
        b=V5wNXnySoTaA7NCUO9h9eVPE+0sBnqbyJnnDcc4EfAb1USUiqdQssc8y4dnN3B+Yll
         4kpw23sEBrt9EgEBSpttoXqSqgybCOoo3lbqZAlttfYK+WR77ctqa4tKdaw7+ET61uMp
         91xLbeVr0pbGHxr5f/8CcpSlY64XlG7kvSPUkTPyM4ADHeDe0CJlly5mYf2tuzUlcK5U
         L6HJwvBUezLrutb3IFvuUv4mjIjXIRHtLnictkvooHG085EQzsWPeGdmbUNlcFXCiPKU
         rPGjEU2/uS/TYRDtdiSGTPHXQnNGF8Cc/8iRqV42judMJLdRBqK+ThPhWc6cqnzKHk1p
         DsLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=HS+u+zhrivtPGNBbCaE1swQKUpAdxESip9XcNifCPoc=;
        b=mon88tQCnPE/CjNgX1G0ESc8xLRLA3NCbG/f37AXVUHm8bKjA7Hjet5s7z6rHkBkaB
         HaWE3wO2Xe/WvAla0HGnJXGnwAcH0btV5j9AZmbRJXWjhvUAv+n4qtOrgZPzmxEWGqTR
         quvEFej8scckmqduQAWsRloFYwF7jOEMgmbm316VxgV17kV9YOOkV0IkHfxEeZDCu49P
         x31UpZcSDnRV69e5PY7oPY/MGkO7VsHxNrfNE+MCkVscc6ZaIhs4Wi6HGNZLNbXzkL3M
         TDpXa6xtsWkVEKMIrhrRGXMvPtDMof8awcbfTDg8QC25Zr32XOsixHszP3jLuHlc+2os
         KjXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AWYLnYQX;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d2si19921360pgi.579.2019.05.13.19.07.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 19:07:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AWYLnYQX;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f54.google.com (mail-wm1-f54.google.com [209.85.128.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 54195216E3
	for <linux-mm@kvack.org>; Tue, 14 May 2019 02:07:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557799669;
	bh=194cYzJSEWelAQdAamSQ+HGCjU5m9KnJ95hz0wnBDOw=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=AWYLnYQXqecynVt8YdrwsS+Xfe7b6aCvx26D2JOr6eOFfLp34kg8+aoO6xKlIGs+n
	 if+Vo2q8fZoCeysFzcDiUsbbBG2udM5TCiMj02dJ8dNOct9/ZqVispF3WQeOuagvIo
	 NudBGjsk7KLG9PNcK2KUdJ8z3KuRVee+3Ctp2/cA=
Received: by mail-wm1-f54.google.com with SMTP id c66so1209363wme.0
        for <linux-mm@kvack.org>; Mon, 13 May 2019 19:07:49 -0700 (PDT)
X-Received: by 2002:a7b:c844:: with SMTP id c4mr6663648wml.108.1557799667844;
 Mon, 13 May 2019 19:07:47 -0700 (PDT)
MIME-Version: 1.0
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrVhRt0vPgcun19VBqAU_sWUkRg1RDVYk4osY6vK0SKzgg@mail.gmail.com> <C2A30CC6-1459-4182-B71A-D8FF121A19F2@oracle.com>
In-Reply-To: <C2A30CC6-1459-4182-B71A-D8FF121A19F2@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 13 May 2019 19:07:36 -0700
X-Gmail-Original-Message-ID: <CALCETrXK8+tUxNA=iVDse31nFRZyiQYvcrQxV1JaidhnL4GC0w@mail.gmail.com>
Message-ID: <CALCETrXK8+tUxNA=iVDse31nFRZyiQYvcrQxV1JaidhnL4GC0w@mail.gmail.com>
Subject: Re: [RFC KVM 00/27] KVM Address Space Isolation
To: Liran Alon <liran.alon@oracle.com>
Cc: Andy Lutomirski <luto@kernel.org>, Alexandre Chartre <alexandre.chartre@oracle.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Peter Zijlstra <peterz@infradead.org>, kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, jan.setjeeilers@oracle.com, 
	Jonathan Adams <jwadams@google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 2:09 PM Liran Alon <liran.alon@oracle.com> wrote:
>
>
>
> > On 13 May 2019, at 21:17, Andy Lutomirski <luto@kernel.org> wrote:
> >
> >> I expect that the KVM address space can eventually be expanded to incl=
ude
> >> the ioctl syscall entries. By doing so, and also adding the KVM page t=
able
> >> to the process userland page table (which should be safe to do because=
 the
> >> KVM address space doesn't have any secret), we could potentially handl=
e the
> >> KVM ioctl without having to switch to the kernel pagetable (thus effec=
tively
> >> eliminating KPTI for KVM). Then the only overhead would be if a VM-Exi=
t has
> >> to be handled using the full kernel address space.
> >>
> >
> > In the hopefully common case where a VM exits and then gets re-entered
> > without needing to load full page tables, what code actually runs?
> > I'm trying to understand when the optimization of not switching is
> > actually useful.
> >
> > Allowing ioctl() without switching to kernel tables sounds...
> > extremely complicated.  It also makes the dubious assumption that user
> > memory contains no secrets.
>
> Let me attempt to clarify what we were thinking when creating this patch =
series:
>
> 1) It is never safe to execute one hyperthread inside guest while it=E2=
=80=99s sibling hyperthread runs in a virtual address space which contains =
secrets of host or other guests.
> This is because we assume that using some speculative gadget (such as hal=
f-Spectrev2 gadget), it will be possible to populate *some* CPU core resour=
ce which could then be *somehow* leaked by the hyperthread running inside g=
uest. In case of L1TF, this would be data populated to the L1D cache.
>
> 2) Because of (1), every time a hyperthread runs inside host kernel, we m=
ust make sure it=E2=80=99s sibling is not running inside guest. i.e. We mus=
t kick the sibling hyperthread outside of guest using IPI.
>
> 3) From (2), we should have theoretically deduced that for every #VMExit,=
 there is a need to kick the sibling hyperthread also outside of guest unti=
l the #VMExit is completed. Such a patch series was implemented at some poi=
nt but it had (obviously) significant performance hit.
>
>
4) The main goal of this patch series is to preserve (2), but to avoid
the overhead specified in (3).
>
> The way this patch series achieves (4) is by observing that during the ru=
n of a VM, most #VMExits can be handled rather quickly and locally inside K=
VM and doesn=E2=80=99t need to reference any data that is not relevant to t=
his VM or KVM code. Therefore, if we will run these #VMExits in an isolated=
 virtual address space (i.e. KVM isolated address space), there is no need =
to kick the sibling hyperthread from guest while these #VMExits handlers ru=
n.

Thanks!  This clarifies a lot of things.

> The hope is that the very vast majority of #VMExit handlers will be able =
to completely run without requiring to switch to full address space. Theref=
ore, avoiding the performance hit of (2).
> However, for the very few #VMExits that does require to run in full kerne=
l address space, we must first kick the sibling hyperthread outside of gues=
t and only then switch to full kernel address space and only once all hyper=
threads return to KVM address space, then allow then to enter into guest.

What exactly does "kick" mean in this context?  It sounds like you're
going to need to be able to kick sibling VMs from extremely atomic
contexts like NMI and MCE.

