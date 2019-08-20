Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD3C0C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 11:42:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E44F214DA
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 11:42:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="YixUBs68"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E44F214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03CED6B0007; Tue, 20 Aug 2019 07:42:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F09006B0008; Tue, 20 Aug 2019 07:42:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF6CF6B000A; Tue, 20 Aug 2019 07:42:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0128.hostedemail.com [216.40.44.128])
	by kanga.kvack.org (Postfix) with ESMTP id B905A6B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:42:08 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 648DF500F
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 11:42:08 +0000 (UTC)
X-FDA: 75842617536.13.toes72_2fb65fc207917
X-HE-Tag: toes72_2fb65fc207917
X-Filterd-Recvd-Size: 4619
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 11:42:07 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id s15so5958411edx.0
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 04:42:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3a3ksvO52CtO/ttkK+4sBJJjCffAnNgMq3ot08D8hTE=;
        b=YixUBs68BTWBicnObm8UhXLg9oTc2+ORLcfgUd/Du/W1MFNGMBmeO9v0CpCKPNDfOL
         IOv3P3Sy0KW3Cf/mHqmQhC5dYF048v5l9MKyEPipLYYbjwxD0H59P87oFZcAUxJs8Bpg
         TZ1aEoxr3qON74esiOLqh6pfyJNutI2zVrynCMtzDWFU5/3lq5/KWMFf5eqyhEf4R0t8
         pbWvw0NqWOv3EnLSCIbWXXsihVYEJL1fI+6iT4Zmbmou9OHn04p1+7PzMZzZ7yyKCqyL
         Kk9JSwipQzT+aeLr8A97jVZmZOhpTYYMCBCuIaYQAxnOVqXF/8pnIkDuPnZxsqpfAfZv
         fUjg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=3a3ksvO52CtO/ttkK+4sBJJjCffAnNgMq3ot08D8hTE=;
        b=Uy8bZ9ooxjDNKuy4di44fLxzsnNmq2sEoE1MKI9hRLivtFCWVoyDD4QL4XrLcndNib
         9hjFE9v6ENbWLfrrcwwTK1gAa/Udkn8v01BTy7Enrdtwqs1ibnHCsafRDf6Ex0nL9AlI
         5tqO0+qmC2c48qSKBFoC4MTNBu94T32ZeUJqL25tIyW9NrUDG+iGy2zV9Z/kcBe2CHL0
         3YwRp+LFAifpFMRA1sTY0HrbHge9ZtiLxj0Zah47RSMoIk36tRIkiB/NOXF0lw88uDaP
         aR/+jHbkKNlmcn2YVh1ro0qkSoQctWRBRpK7wdzk3k6jGTEK4JF06KZTlOWv4mettBBL
         oPOA==
X-Gm-Message-State: APjAAAV3ZhJSFIDX+tf83o3prF99he1mDYa78zJC9bgbkTHer9SqkOnM
	hdlGpldWfgCWWWVvHcg94YvH7Dlw85gU3dPgcfoUgQ==
X-Google-Smtp-Source: APXvYqys5DbTiUd9mTqbI3sEh4h1TdEgJjNdpUHqISVmYQkhBiZ+C1YQY1SvjKZBeVx8+M4TD3mTf8Wtu+RfofBl0sA=
X-Received: by 2002:a17:906:1112:: with SMTP id h18mr26088394eja.165.1566301326474;
 Tue, 20 Aug 2019 04:42:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190817024629.26611-1-pasha.tatashin@soleen.com>
 <20190817024629.26611-4-pasha.tatashin@soleen.com> <20190819155824.GE9927@lakrids.cambridge.arm.com>
 <CA+CK2bD4zE6eieSW2OLQwOQC7=4ncDc8wK6ZjhDO3Dv+BUqnzQ@mail.gmail.com> <20190820113000.GA49252@lakrids.cambridge.arm.com>
In-Reply-To: <20190820113000.GA49252@lakrids.cambridge.arm.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Tue, 20 Aug 2019 07:41:55 -0400
Message-ID: <CA+CK2bDcS-nSLhSjuwEStnxD4FrA+P0LvyQfqKy4g1zaqXZPrQ@mail.gmail.com>
Subject: Re: [PATCH v2 03/14] arm64, hibernate: add trans_table public functions
To: Mark Rutland <mark.rutland@arm.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, kexec mailing list <kexec@lists.infradead.org>, 
	LKML <linux-kernel@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
	Catalin Marinas <catalin.marinas@arm.com>, will@kernel.org, 
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

> > > While the architecture uses the term 'translation table', in the kernel
> > > we generally use 'pgdir' or 'pgd' to refer to the tables, so please keep
> > > to that naming scheme.
> >
> > The idea is to have a unique name space for new subsystem of page
> > tables that are used between kernels:
> > between stage 1 and stage 2 kexec kernel, and similarly between
> > kernels during hibernate boot process.
> >
> > I picked: "trans_table" that stands for transitional page table:
> > meaning they are used only during transition between worlds.
> >
> > All public functions in this subsystem will have trans_table_* prefix,
> > and page directory will be named: "trans_table". If this is confusing,
> > I can either use a different prefix, or describe what "trans_table"
> > stand for in trans_table.h/.c
>
> Ok.
>
> I think that "trans_table" is unfortunately confusing, as it clashes
> with the architecture terminology, and differs from what we have
> elsewhere.
>
> I think that "trans_pgd" would be better, as that better aligns with
> what we have elsewhere, and avoids the ambiguity.
>

Sounds good. I will rename trans_table* with trans_pgd*, and will also
add a note to the comments explaining what it stands for.

Thank you,
Pasha

