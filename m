Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7054C606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 04:16:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B3602073D
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 04:16:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rh0MMkIW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B3602073D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0ABBE8E003C; Tue,  9 Jul 2019 00:16:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0336C8E0032; Tue,  9 Jul 2019 00:16:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF05C8E003C; Tue,  9 Jul 2019 00:16:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id BBA4C8E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 00:16:28 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id s9so18369207iob.11
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 21:16:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=mHFhQljdP11Vu4ABp5SegdN4vZ9Y4ZYLAQNxi7/E2Po=;
        b=lgBnf2F2Dm1eG8/vN8hw1vpokgNWmy3zPworTk9AmBpe3rbvZkyAZTsvnkOrUoyjWP
         GSaSRg44Q87e92WpVte2s1sPR5o4ZI8jo2B4Z8dp5o/pdJE6TjStGVmmFTAImwiuq6Et
         UHq8v8SnVChA5Iqg05QY+PuIBVZa2CJob8bNvzEO8KE1bo8QmRjbWar8IkZ1jgExFibs
         68/vzYCBNLbAZNKOnzN73vGUZMrGOVON7ARAKysJpirzHILcx4pRYpYPjDaVg/Cl6Pit
         WfxLeS+DOekf14MenlFEFm9nfiEx6rl/tHX2F8hcZclqzKCOQQ5fBphIaMSkw29Ri7F5
         xsjw==
X-Gm-Message-State: APjAAAVmY7diOXLCjhEepYHDWiEdHQk5g2/FFCE9CLDJ6pZ8bucZoZnm
	1E4P1SR3mMrsOM5sn8XqBxB94dQ6QAIODkLZPMYIrR7KFkYych1D1uN5xB7Gpj7sbPNPkIIN2YB
	h5cooz32StToYJZYzEEILuZtzZKTdK1oBuWwOIrB8LXpdBYxyBDy0bzYEG77oxp5RmQ==
X-Received: by 2002:a5d:968b:: with SMTP id m11mr2967270ion.16.1562645788468;
        Mon, 08 Jul 2019 21:16:28 -0700 (PDT)
X-Received: by 2002:a5d:968b:: with SMTP id m11mr2967214ion.16.1562645787635;
        Mon, 08 Jul 2019 21:16:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562645787; cv=none;
        d=google.com; s=arc-20160816;
        b=TZd9O4bC6SRLniizO0URqzOfM2lXYwjafTfXHFUPk9z4j5X7OeYDvJGqOTQvpzWtfu
         xWxIPsMpGXzr259KtCut4ZJV0gKDOdmYfPqwolghBHsJqFp+1rXpsxJ86mMMk+PjE3oJ
         ggV97vJyU+dYJg2UQvHa1GvU7Dv3zDo0EPoolH4Flr3DwKs/kTFWmcP7CN/wZKtE7B8w
         pur7N1HDtDiG6Ch6nRfHxwcSZ4+Jx2c2I+Mb9LeqIQHRJZHmgW4Ee+8uUe1CXLCyKvrG
         GxW8jjR5u+w+QHxuaeQLgf8g22bF/YIewmO8pjCHEKxIVbWeZzPfTqBqxYhQCN4CcuKj
         FRVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=mHFhQljdP11Vu4ABp5SegdN4vZ9Y4ZYLAQNxi7/E2Po=;
        b=G3UILRU6pNXfDlN+c6RmvRYuSnSO6W5QQq6JHeuGJeaAIaL+jODYNO2UX9qsLp9BTN
         7ti0n5ObiVG2FC1Mf6ELuR8K1VQ0GGMzGc5yEYSJGkD1Mm3TBY6VyGEe4keNjc4iJJDa
         RIxR8l9OXmLXG7YfvJX4H+PXkOI3KNZt/OMykn5Xu4PfOH8yvf/c1OVzj+urKU5AShPi
         8ov31HqbJfGLHavxo+3q9SK49ZhB5OzM9PaadhXQNLOVbHRCKB6brrS7WZN1JjZb7yX/
         wyYdWmRqhV1nnwZ93UoJjoauRUFr+/sKh99IkJzWE1FgCM7xT2ew0rxTHtODwFFoDB4W
         4zKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rh0MMkIW;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r3sor13217489jai.10.2019.07.08.21.16.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 21:16:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rh0MMkIW;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mHFhQljdP11Vu4ABp5SegdN4vZ9Y4ZYLAQNxi7/E2Po=;
        b=rh0MMkIWPs5sC69e8D8dbM1sJnHyeRNJ0DZmzbBWCvEqA0OO1IfkadPel4SwEQfI0o
         6dSY44Sfqt4dbAhiUmpC6OgNj8h5r/UMTsc0HM3X+4/keBqaB7uMMdxnUGRgmarh4iwn
         AQ9Jj0CiinJtQrx2wJyRO2RbGLuLSZEE/3NDDX0ThaK/8fKobmp+mGd48Dd3SPRB1NQm
         QWYz73CS1OhEbNkbLUrma9MR10pYVR4ImVojuuPSwGiHssj5A7A75mfhBRstN8y62cQ8
         Am6oj3Cwv8w/rsgRZbLlTYE1Ws5L2ah9rAaDaX975IPsNW4pihX8zsKMw6kbLMU8PRFi
         p9tA==
X-Google-Smtp-Source: APXvYqzbwCQ1U6DYCLm/XiAtG2sygEfA+gx4rzAtRMr3xWKqX7/a1mv8W7atago53ZRkvac0CouM1vs1LWi0xZDxBQc=
X-Received: by 2002:a02:b713:: with SMTP id g19mr2855704jam.77.1562645787339;
 Mon, 08 Jul 2019 21:16:27 -0700 (PDT)
MIME-Version: 1.0
References: <1562300143-11671-1-git-send-email-kernelfans@gmail.com>
 <1562300143-11671-2-git-send-email-kernelfans@gmail.com> <alpine.DEB.2.21.1907072133310.3648@nanos.tec.linutronix.de>
 <CAFgQCTvwS+yEkAmCJnsCfnr0JS01OFtBnDg4cr41_GqU79A4Gg@mail.gmail.com> <alpine.DEB.2.21.1907081125300.3648@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1907081125300.3648@nanos.tec.linutronix.de>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 9 Jul 2019 12:16:15 +0800
Message-ID: <CAFgQCTvAOeerLHQvgvFXy_kLs=H=CuUFjYE+UAN+vhPCG+s=pQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] x86/numa: instance all parsed numa node
To: Thomas Gleixner <tglx@linutronix.de>
Cc: x86@kernel.org, Michal Hocko <mhocko@suse.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, 
	Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>, 
	Pavel Tatashin <pavel.tatashin@microsoft.com>, Mel Gorman <mgorman@techsingularity.net>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, Qian Cai <cai@lca.pw>, Barret Rhoden <brho@google.com>, 
	Bjorn Helgaas <bhelgaas@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 8, 2019 at 5:35 PM Thomas Gleixner <tglx@linutronix.de> wrote:
>
> On Mon, 8 Jul 2019, Pingfan Liu wrote:
> > On Mon, Jul 8, 2019 at 3:44 AM Thomas Gleixner <tglx@linutronix.de> wrote:
> > >
> > > On Fri, 5 Jul 2019, Pingfan Liu wrote:
> > >
> > > > I hit a bug on an AMD machine, with kexec -l nr_cpus=4 option. nr_cpus option
> > > > is used to speed up kdump process, so it is not a rare case.
> > >
> > > But fundamentally wrong, really.
> > >
> > > The rest of the CPUs are in a half baken state and any broadcast event,
> > > e.g. MCE or a stray IPI, will result in a undiagnosable crash.
> > Very appreciate if you can pay more word on it? I tried to figure out
> > your point, but fail.
> >
> > For "a half baked state", I think you concern about LAPIC state, and I
> > expand this point like the following:
>
> It's not only the APIC state. It's the state of the CPUs in general.
For other states, "kexec -l " is a kind of boot loader and the boot
cpu complies with the kernel boot up provision. As for the rest AP,
they are pinged at loop before receiving #INIT IPI. Then the left
things is the same as SMP boot up.

>
> > For IPI: when capture kernel BSP is up, the rest cpus are still loop
> > inside crash_nmi_callback(), so there is no way to eject new IPI from
> > these cpu. Also we disable_local_APIC(), which effectively prevent the
> > LAPIC from responding to IPI, except NMI/INIT/SIPI, which will not
> > occur in crash case.
>
> Fair enough for the IPI case.
>
> > For MCE, I am not sure whether it can broadcast or not between cpus,
> > but as my understanding, it can not. Then is it a problem?
>
> It can and it does.
>
> That's the whole point why we bring up all CPUs in the 'nosmt' case and
> shut the siblings down again after setting CR4.MCE. Actually that's in fact
> a 'let's hope no MCE hits before that happened' approach, but that's all we
> can do.
>
> If we don't do that then the MCE broadcast can hit a CPU which has some
> firmware initialized state. The result can be a full system lockup, triple
> fault etc.
>
> So when the MCE hits a CPU which is still in the crashed kernel lala state,
> then all hell breaks lose.
Thank you for the comprehensive explain. With your guide, now, I have
a full understanding of the issue.

But when I tried to add something to enable CR4.MCE in
crash_nmi_callback(), I realized that it is undo-able in some case (if
crashed, we will not ask an offline smt cpu to online), also it is
needless. "kexec -l/-p" takes the advantage of the cpu state in the
first kernel, where all logical cpu has CR4.MCE=1.

So kexec is exempt from this bug if the first kernel already do it.
>
> > From another view point, is there any difference between nr_cpus=1 and
> > nr_cpus> 1 in crashing case? If stray IPI raises issue to nr_cpus>1,
> > it does for nr_cpus=1.
>
> Anything less than the actual number of present CPUs is problematic except
> you use the 'let's hope nothing happens' approach. We could add an option
> to stop the bringup at the early online state similar to what we do for
> 'nosmt'.
Yes, we should do something about nr_cpus param for the first kernel.

Thanks,
  Pingfan

