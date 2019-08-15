Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46071C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:16:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED7E1205F4
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:16:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="pKHPfBNQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED7E1205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C1556B02DC; Thu, 15 Aug 2019 13:16:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8732C6B02DD; Thu, 15 Aug 2019 13:16:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73AB96B02DE; Thu, 15 Aug 2019 13:16:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0181.hostedemail.com [216.40.44.181])
	by kanga.kvack.org (Postfix) with ESMTP id 53E6D6B02DC
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:16:33 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 0CB98180AD802
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:16:33 +0000 (UTC)
X-FDA: 75825316266.21.angle34_391abc2c2e604
X-HE-Tag: angle34_391abc2c2e604
X-Filterd-Recvd-Size: 7134
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:16:32 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id x19so2681721eda.12
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 10:16:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to;
        bh=HvH/9QkJPpLkWxDBArczHr4uoHoZvdo767/gla+0Cq4=;
        b=pKHPfBNQUfx3iIaUdBEjdoQBnwVE33BsffdbfdtS4c7cz0NChF2ssj7n0oUNYvLBml
         1GW7C9tC38qeN54CAe2livGh5ZgyPHx1kBuk/IvtFXrnFpJB8Ek/GI0NZfSHqLaPD9oi
         2UtsZ5gQknSqtRiljMnlxI6c8SaAZBr3tZ3nhrRXJUZrIF7INC4o3B2dXzMQTBEzum7c
         jLOY3vrE7M080p/0Pboi6nDaUWr6lRajGfmDoPJJol5qFQmqtvJbODsLpb22T2hQaxvL
         NgnhaiHSKPHsKDlHk1m/gx0MjaiOiKCkfxPxDFJOO4hcsmg0h7rmTCnKZY6RTOJVN9Jc
         fE/g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to;
        bh=HvH/9QkJPpLkWxDBArczHr4uoHoZvdo767/gla+0Cq4=;
        b=fO7jbxVxbXCQVUuBBscUmBOezKy+D+OZHEM3dLJfQJcu2ziDUf3mx6zFeaVWOyr3kL
         iLyZZY4VwAQA/koN2Ej2H+hr39F1/xgjAXIMHFYlgIYsxaMZRr9xNU0AW07BFz3OOQFz
         6s5hGEh2dHzsHOq7jzcJyYjDDZJZ7SmmULrzGs3ZbKMxmFnU2gWGqY+DnBflRZ1jyhkp
         sxhs83ia4a4Uo+QgT9djIJvtUYcITG9UyCW9hEEKEsxqwewguFGJoAWfHJy0K3XV1gtq
         lyUOuneYAF8K/ShfU3wGU9veMMJqE0+ZM3RcgbFR7AMGzTRo/hPAefdzVPywlnAPoWIs
         BHBQ==
X-Gm-Message-State: APjAAAUr3Nyo0mu4vLNBfv8CsGFuJq3uh9PVcqRf+HULX6VSteOto4t1
	1dWzofxy0WBk7rEUBtaYmmT+xGg7aubgbyCWZtSIcIwG
X-Google-Smtp-Source: APXvYqxjQMegw/1NCxtxkMv+zw0eXzahg5VKDPdm64IBjqfvOgF3V96t+tXb8M/4zCohVqTP+H/B/YvKeSv6kTxEdbs=
X-Received: by 2002:aa7:d48c:: with SMTP id b12mr6512796edr.170.1565889391108;
 Thu, 15 Aug 2019 10:16:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190801152439.11363-1-pasha.tatashin@soleen.com> <CA+CK2bADiBMEx9cJuXT5fQkBYFZAtxUtc7ZzjrNfEjijPZkPtw@mail.gmail.com>
In-Reply-To: <CA+CK2bADiBMEx9cJuXT5fQkBYFZAtxUtc7ZzjrNfEjijPZkPtw@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 15 Aug 2019 13:16:20 -0400
Message-ID: <CA+CK2bD6e2WGxuPG+jX8c_qyHNZOC=8NZ-wVZXQuMS2ncBNndg@mail.gmail.com>
Subject: Re: [PATCH v1 0/8] arm64: MMU enabled kexec relocation
To: Pavel Tatashin <pasha.tatashin@soleen.com>, James Morris <jmorris@namei.org>, 
	Sasha Levin <sashal@kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, 
	kexec mailing list <kexec@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, 
	Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, will@kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, Marc Zyngier <marc.zyngier@arm.com>, 
	James Morse <james.morse@arm.com>, Vladimir Murzin <vladimir.murzin@arm.com>, 
	Matthias Brugger <matthias.bgg@gmail.com>, Bhupesh Sharma <bhsharma@redhat.com>, 
	linux-mm <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

It is been two weeks, and no review activity yet. Please help with
reviewing this work.

Thank you,
Pasha

On Thu, Aug 8, 2019 at 2:44 PM Pavel Tatashin <pasha.tatashin@soleen.com> wrote:
>
> Just a friendly reminder, please send your comments on this series.
> It's been a week since I sent out these patches, and no feedback yet.
> Also, I'd appreciate if anyone could test this series on vhe hardware
> with vhe kernel, it does not look like QEMU can emulate it yet
>
> Thank you,
> Pasha
>
> On Thu, Aug 1, 2019 at 11:24 AM Pavel Tatashin
> <pasha.tatashin@soleen.com> wrote:
> >
> > Enable MMU during kexec relocation in order to improve reboot performance.
> >
> > If kexec functionality is used for a fast system update, with a minimal
> > downtime, the relocation of kernel + initramfs takes a significant portion
> > of reboot.
> >
> > The reason for slow relocation is because it is done without MMU, and thus
> > not benefiting from D-Cache.
> >
> > Performance data
> > ----------------
> > For this experiment, the size of kernel plus initramfs is small, only 25M.
> > If initramfs was larger, than the improvements would be greater, as time
> > spent in relocation is proportional to the size of relocation.
> >
> > Previously:
> > kernel shutdown 0.022131328s
> > relocation      0.440510736s
> > kernel startup  0.294706768s
> >
> > Relocation was taking: 58.2% of reboot time
> >
> > Now:
> > kernel shutdown 0.032066576s
> > relocation      0.022158152s
> > kernel startup  0.296055880s
> >
> > Now: Relocation takes 6.3% of reboot time
> >
> > Total reboot is x2.16 times faster.
> >
> > Previous approaches and discussions
> > -----------------------------------
> > https://lore.kernel.org/lkml/20190709182014.16052-1-pasha.tatashin@soleen.com
> > reserve space for kexec to avoid relocation, involves changes to generic code
> > to optimize a problem that exists on arm64 only:
> >
> > https://lore.kernel.org/lkml/20190716165641.6990-1-pasha.tatashin@soleen.com
> > The first attempt to enable MMU, some bugs that prevented performance
> > improvement. The page tables unnecessary configured idmap for the whole
> > physical space.
> >
> > https://lore.kernel.org/lkml/20190731153857.4045-1-pasha.tatashin@soleen.com
> > No linear copy, bug with EL2 reboots.
> >
> > Pavel Tatashin (8):
> >   kexec: quiet down kexec reboot
> >   arm64, mm: transitional tables
> >   arm64: hibernate: switch to transtional page tables.
> >   kexec: add machine_kexec_post_load()
> >   arm64, kexec: move relocation function setup and clean up
> >   arm64, kexec: add expandable argument to relocation function
> >   arm64, kexec: configure transitional page table for kexec
> >   arm64, kexec: enable MMU during kexec relocation
> >
> >  arch/arm64/Kconfig                     |   4 +
> >  arch/arm64/include/asm/kexec.h         |  51 ++++-
> >  arch/arm64/include/asm/pgtable-hwdef.h |   1 +
> >  arch/arm64/include/asm/trans_table.h   |  68 ++++++
> >  arch/arm64/kernel/asm-offsets.c        |  14 ++
> >  arch/arm64/kernel/cpu-reset.S          |   4 +-
> >  arch/arm64/kernel/cpu-reset.h          |   8 +-
> >  arch/arm64/kernel/hibernate.c          | 261 ++++++-----------------
> >  arch/arm64/kernel/machine_kexec.c      | 199 ++++++++++++++----
> >  arch/arm64/kernel/relocate_kernel.S    | 196 +++++++++---------
> >  arch/arm64/mm/Makefile                 |   1 +
> >  arch/arm64/mm/trans_table.c            | 273 +++++++++++++++++++++++++
> >  kernel/kexec.c                         |   4 +
> >  kernel/kexec_core.c                    |   8 +-
> >  kernel/kexec_file.c                    |   4 +
> >  kernel/kexec_internal.h                |   2 +
> >  16 files changed, 758 insertions(+), 340 deletions(-)
> >  create mode 100644 arch/arm64/include/asm/trans_table.h
> >  create mode 100644 arch/arm64/mm/trans_table.c
> >
> > --
> > 2.22.0
> >

