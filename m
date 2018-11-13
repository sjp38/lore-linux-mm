Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id C09F56B0007
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 06:26:25 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id n3-v6so2802173oia.3
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 03:26:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q125-v6sor8626279oia.48.2018.11.13.03.26.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 03:26:24 -0800 (PST)
Received: from mail-ot1-f43.google.com (mail-ot1-f43.google.com. [209.85.210.43])
        by smtp.gmail.com with ESMTPSA id k7-v6sm3931659oib.44.2018.11.13.03.26.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 03:26:22 -0800 (PST)
Received: by mail-ot1-f43.google.com with SMTP id t5so10999054otk.1
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 03:26:22 -0800 (PST)
MIME-Version: 1.0
References: <20181112231344.7161-1-timofey.titovets@synesis.ru> <20181113014928.GH21824@bombadil.infradead.org>
In-Reply-To: <20181113014928.GH21824@bombadil.infradead.org>
From: Timofey Titovets <timofey.titovets@synesis.ru>
Date: Tue, 13 Nov 2018 14:25:45 +0300
Message-ID: <CAGqmi76_ftDGtyowNRz7CCxRoJ6U3L747M=dWbRjh357w3=ZKA@mail.gmail.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-doc@vger.kernel.org

=D0=B2=D1=82, 13 =D0=BD=D0=BE=D1=8F=D0=B1. 2018 =D0=B3. =D0=B2 04:49, Matth=
ew Wilcox <willy@infradead.org>:
>
> On Tue, Nov 13, 2018 at 02:13:44AM +0300, Timofey Titovets wrote:
> > Some numbers from different not madvised workloads.
> > Formulas:
> >   Percentage ratio =3D (pages_sharing - pages_shared)/pages_unshared
> >   Memory saved =3D (pages_sharing - pages_shared)*4/1024 MiB
> >   Memory used =3D free -h
> >
> >   * Name: My working laptop
> >     Description: Many different chrome/electron apps + KDE
> >     Ratio: 5%
> >     Saved: ~100  MiB
> >     Used:  ~2000 MiB
>
> Your _laptop_ saves 100MB of RAM?  That's extraordinary.  Essentially
> that's like getting an extra 100MB of page cache for free.  Is there
> any observable slowdown?  I could even see there being a speedup (due
> to your working set being allowed to be 5% larger)
>
> I am now a big fan of this patch and shall try to give it the review
> that it deserves.

I'm not sure if this is sarcasm,
anyway i try do my best to get that working.

On any x86 desktop with mixed load (browser, docs, games & etc)
You will always see something like 40-200 MiB of deduped pages,
based on type of load of course.

I'm just don't try use that numbers as reason to get general KSM
deduplication in kernel.
Because in current generation with several gigabytes of memory,
several saved MiB not looks serious for most of people.

Thanks!
