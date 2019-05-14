Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1063C04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 20:33:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72D222168B
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 20:33:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="U/yY8Nvh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72D222168B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA1B66B0005; Tue, 14 May 2019 16:33:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E519F6B0006; Tue, 14 May 2019 16:33:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D42216B0007; Tue, 14 May 2019 16:33:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7D76B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 16:33:36 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e69so276062pgc.7
        for <linux-mm@kvack.org>; Tue, 14 May 2019 13:33:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yav7d1wlPb+DvwhGNViqHCLh8/mNKXZ8fYeFkNMpf4w=;
        b=ZcKC156EFH/xHHBmYfqRI3t4CqAwI+ZbUJqYpf/ozh6Mc2Ab0vcIGbcfb4E22YB5zC
         +Dkv7Cg949+6rJnGbjxQP+A9migChs8VCdc3+/RtXEJ4vEvb5XOMkSnz01CPgxUc/AeG
         VMo6WgkzFczXtLhsf8no9YaeKUoOAqK9une0AH6WRHhDcuoJ0/HD/evjO4/cklBYwAUR
         fS8e1RSrVRAI+ugLk0vUxUDxcZLHjxCwlk7HaFXdPIKkfdOkGyhmB8iW3jNLke3S67tI
         4fdN4taMZG892bxhEwMLpPYwttI6Rt32Gp1V5e0/ZHWbitH/0N3Z2tTSXGi7B7MwCL85
         Ri1Q==
X-Gm-Message-State: APjAAAVLEHSSxR69vNYQKpcXwlEGnPW8i/dIx1zrh+6IHw16MXItlr/x
	+H+zTBpkXgacbZpTSaONlumSsFZbS54nSEiLoJbpF+1p9VxhB1FtOEu11rauSWpgNZr/CMW7XkJ
	xnbo0PrXqJgbQdM3GFliv+KFBdc3MsleXImvScJma1Y7Pk2kq8n3XgookyWRYGM3g2Q==
X-Received: by 2002:a17:902:b495:: with SMTP id y21mr39438059plr.143.1557866016185;
        Tue, 14 May 2019 13:33:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLzdG/1q+5RyaySGX3qFbNzJm1FTHY9VzuiBV13NI+k3ovCWihJ5zQ3uIEQR4oq5YVAeFj
X-Received: by 2002:a17:902:b495:: with SMTP id y21mr39437969plr.143.1557866014855;
        Tue, 14 May 2019 13:33:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557866014; cv=none;
        d=google.com; s=arc-20160816;
        b=JnKVY3Y92BJGNbSmKTe+hpy5nWiM3tLQL1EQTcw+0jmy4W3K8v9e/D5v96SGpMsm2q
         j37OkTDrAfPkcFI4qM7/iawaxaiRMiEJWLzbgc2LX+FG3iBK9IT1yi+C1KHfcd7lLxt6
         Kt9edkgx0eh6xoa5Aal0QQmFJwR9HV9kE2BnWjDtAnnGL2TIfxfKQzUYXz0QjEbtlCB4
         cV0TOI2tsFprO4QP0ZTHt11YusFo3Qy8nbnsIc0CpcbOO7U72RNdjuDOhhOLFG/YYMid
         dxdzcE04m1+sNg9zExJCe2aJLf5gCuDI4TL+WU/lnJgx+wjOyr6pS6lj34n+YPS7uJM8
         ZhcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yav7d1wlPb+DvwhGNViqHCLh8/mNKXZ8fYeFkNMpf4w=;
        b=NvV7iHaeJVudWewngQ8Fx+lrWQqv7iv8AMQND+N/srs+/5GRhx5478DaWR6kfx/+iQ
         cppQs3PpbPtyELib4p3r0JbiWY+nD9jW6hdKywjOE5zGd1EFPRKp6l+pBdOVRzJYzfuH
         v9lDFtHzKJG68K4xwqFzTmGuD/2ny3U/Cz3OhCy12d2CvpPROTZZB5hJmMhoh01Bp+hd
         EkV3OZBRmWpmgE8X3VGVkazAHjFtGmMVc03pxdbNGyKpDmwbwXp/2zMQOu0O2BDW4LR/
         aFFEte5U232oPwTU3W7cT/qeShVmKWYhzlMBN1R8T7JoXJbD7z/vkqX1FondUXM6xPyj
         cxXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="U/yY8Nvh";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e15si20894382pgm.377.2019.05.14.13.33.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 13:33:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="U/yY8Nvh";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f54.google.com (mail-wm1-f54.google.com [209.85.128.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4163E21773
	for <linux-mm@kvack.org>; Tue, 14 May 2019 20:33:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557866014;
	bh=/S2BDC6o9SOizwLDYiMYffbUvwSokVCxv3BmfflaHzY=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=U/yY8Nvhi8iji1+459+sjubgg/1JF0X07D7wRnqqKjlo6h1Ahjbdv/0J0MnwVVdl5
	 PvBDOd4AkYiGhiqxEc6ukoCYeoOoDLIXKbu/M85AdHMxpL9STA5P0oBhzNoLQvnalz
	 Wel3PIj0edEHiSp4UKTwYSZR0xDnIvhhppn9Cwe8=
Received: by mail-wm1-f54.google.com with SMTP id c66so3175852wme.0
        for <linux-mm@kvack.org>; Tue, 14 May 2019 13:33:34 -0700 (PDT)
X-Received: by 2002:a1c:a745:: with SMTP id q66mr11466245wme.83.1557866012756;
 Tue, 14 May 2019 13:33:32 -0700 (PDT)
MIME-Version: 1.0
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-19-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrWUKZv=wdcnYjLrHDakamMBrJv48wp2XBxZsEmzuearRQ@mail.gmail.com>
 <20190514070941.GE2589@hirez.programming.kicks-ass.net> <b8487de1-83a8-2761-f4a6-26c583eba083@oracle.com>
 <B447B6E8-8CEF-46FF-9967-DFB2E00E55DB@amacapital.net> <4e7d52d7-d4d2-3008-b967-c40676ed15d2@oracle.com>
 <CALCETrXtwksWniEjiWKgZWZAyYLDipuq+sQ449OvDKehJ3D-fg@mail.gmail.com>
 <e5fedad9-4607-0aa4-297e-398c0e34ae2b@oracle.com> <20190514170522.GW2623@hirez.programming.kicks-ass.net>
 <20190514180936.GA1977@linux.intel.com>
In-Reply-To: <20190514180936.GA1977@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 14 May 2019 13:33:21 -0700
X-Gmail-Original-Message-ID: <CALCETrVzbBLokip5n0KEyG6irH6aoEWqyNODTy8embpXhB1GQg@mail.gmail.com>
Message-ID: <CALCETrVzbBLokip5n0KEyG6irH6aoEWqyNODTy8embpXhB1GQg@mail.gmail.com>
Subject: Re: [RFC KVM 18/27] kvm/isolation: function to copy page table
 entries for percpu buffer
To: Sean Christopherson <sean.j.christopherson@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Alexandre Chartre <alexandre.chartre@oracle.com>, 
	Andy Lutomirski <luto@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, jan.setjeeilers@oracle.com, 
	Liran Alon <liran.alon@oracle.com>, Jonathan Adams <jwadams@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 11:09 AM Sean Christopherson
<sean.j.christopherson@intel.com> wrote:
>
> On Tue, May 14, 2019 at 07:05:22PM +0200, Peter Zijlstra wrote:
> > On Tue, May 14, 2019 at 06:24:48PM +0200, Alexandre Chartre wrote:
> > > On 5/14/19 5:23 PM, Andy Lutomirski wrote:
> >
> > > > How important is the ability to enable IRQs while running with the KVM
> > > > page tables?
> > > >
> > >
> > > I can't say, I would need to check but we probably need IRQs at least for
> > > some timers. Sounds like you would really prefer IRQs to be disabled.
> > >
> >
> > I think what amluto is getting at, is:
> >
> > again:
> >       local_irq_disable();
> >       switch_to_kvm_mm();
> >       /* do very little -- (A) */
> >       VMEnter()
> >
> >               /* runs as guest */
> >
> >       /* IRQ happens */
> >       WMExit()
> >       /* inspect exit raisin */
> >       if (/* IRQ pending */) {
> >               switch_from_kvm_mm();
> >               local_irq_restore();
> >               goto again;
> >       }
> >
> >
> > but I don't know anything about VMX/SVM at all, so the above might not
> > be feasible, specifically I read something about how VMX allows NMIs
> > where SVM did not somewhere around (A) -- or something like that,
> > earlier in this thread.
>
> For IRQs it's somewhat feasible, but not for NMIs since NMIs are unblocked
> on VMX immediately after VM-Exit, i.e. there's no way to prevent an NMI
> from occuring while KVM's page tables are loaded.
>
> Back to Andy's question about enabling IRQs, the answer is "it depends".
> Exits due to INTR, NMI and #MC are considered high priority and are
> serviced before re-enabling IRQs and preemption[1].  All other exits are
> handled after IRQs and preemption are re-enabled.
>
> A decent number of exit handlers are quite short, e.g. CPUID, most RDMSR
> and WRMSR, any event-related exit, etc...  But many exit handlers require
> significantly longer flows, e.g. EPT violations (page faults) and anything
> that requires extensive emulation, e.g. nested VMX.  In short, leaving
> IRQs disabled across all exits is not practical.
>
> Before going down the path of figuring out how to handle the corner cases
> regarding kvm_mm, I think it makes sense to pinpoint exactly what exits
> are a) in the hot path for the use case (configuration) and b) can be
> handled fast enough that they can run with IRQs disabled.  Generating that
> list might allow us to tightly bound the contents of kvm_mm and sidestep
> many of the corner cases, i.e. select VM-Exits are handle with IRQs
> disabled using KVM's mm, while "slow" VM-Exits go through the full context
> switch.

I suspect that the context switch is a bit of a red herring.  A
PCID-don't-flush CR3 write is IIRC under 300 cycles.  Sure, it's slow,
but it's probably minor compared to the full cost of the vm exit.  The
pain point is kicking the sibling thread.

When I worked on the PTI stuff, I went to great lengths to never have
a copy of the vmalloc page tables.  The top-level entry is either
there or it isn't, so everything is always in sync.  I'm sure it's
*possible* to populate just part of it for this KVM isolation, but
it's going to be ugly.  It would be really nice if we could avoid it.
Unfortunately, this interacts unpleasantly with having the kernel
stack in there.  We can freely use a different stack (the IRQ stack,
for example) as long as we don't schedule, but that means we can't run
preemptable code.

Another issue is tracing, kprobes, etc -- I don't think anyone will
like it if a kprobe in KVM either dramatically changes performance by
triggering isolation exits or by crashing.  So you may need to
restrict the isolated code to a file that is compiled with tracing off
and has everything marked NOKPROBE.  Yuck.

I hate to say this, but at what point do we declare that "if you have
SMT on, you get to keep both pieces, simultaneously!"?

