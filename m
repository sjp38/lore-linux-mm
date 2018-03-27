Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id B8BB56B0024
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 08:31:26 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 30-v6so10518486ple.19
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 05:31:26 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id u9si809035pgc.790.2018.03.27.05.31.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 05:31:25 -0700 (PDT)
Received: from epcas5p4.samsung.com (unknown [182.195.41.42])
	by mailout4.samsung.com (KnoxPortal) with ESMTP id 20180327123124epoutp0443dd5ea9691f62f11b02b4e8fe2ee844~fxuSdjTgW2358123581epoutp04T
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 12:31:24 +0000 (GMT)
Mime-Version: 1.0
Subject: Re: [PATCH v2] mm/page_owner: ignore everything below the IRQ entry
 point
Reply-To: maninder1.s@samsung.com
From: Maninder Singh <maninder1.s@samsung.com>
In-Reply-To: <20180326125228.1f40abb9a52f3674b1491aea@linux-foundation.org>
Message-ID: <20180327114019epcms5p41dec80bebd551f85f576d90ff144fba8@epcms5p4>
Date: Tue, 27 Mar 2018 17:10:19 +0530
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"
References: <20180326125228.1f40abb9a52f3674b1491aea@linux-foundation.org>
	<CACT4Y+Yfx+fTHyQ=d3T68bwfgQQsmqd+e72V67kaAHajo536JA@mail.gmail.com>
	<1522058304-35934-1-git-send-email-maninder1.s@samsung.com>
	<20180326141717epcms5p4064a0fd4f594b2ff434f9b05cd1ea5ad@epcms5p4>
	<CGME20180326100020epcas5p2b50b7541e66dccf4e49db634e5fe6b41@epcms5p4>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vaneet Narang <v.narang@samsung.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Kate Stewart <kstewart@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.com>, "vinmenon@codeaurora.org" <vinmenon@codeaurora.org>, "gomonovych@gmail.com" <gomonovych@gmail.com>, Ayush Mittal <ayush.m@samsung.com>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, PANKAJ MISHRA <pankaj.m@samsung.com>

Hi Andrew,

>filter_irq_stacks()=C2=A0is=C2=A0too=C2=A0large=C2=A0to=C2=A0be=C2=A0inlin=
ed.=0D=0A=C2=A0=0D=0AOk=20we=20are=20thinking=20to=20move=20definations=20i=
n=20kernel/stacktrace.c=0D=0Aas=20a=20normal=20global=20function.=0D=0A=C2=
=A0=0D=0A=0D=0A>in_irqentry_text()=C2=A0is=C2=A0probably=C2=A0too=C2=A0larg=
e=C2=A0to=C2=A0be=C2=A0inlined=C2=A0as=C2=A0well,=C2=A0and=0D=0A>should=C2=
=A0return=C2=A0bool.=0D=0A=0D=0AWe=20can=20declare=20it=20as=20static=20fun=
citon=20in=20kernel/stacktrace.c=20as=20its=20user=0D=0Ais=20only=20filter_=
irq_stacks.=0D=0A=C2=A0=0D=0A>Declarations=C2=A0for=C2=A0__irqentry_text_st=
art=C2=A0and=C2=A0friends=C2=A0already=C2=A0exist=C2=A0in=0D=0A>include/asm=
-generic/sections.h=C2=A0(and,=C2=A0for=C2=A0some=C2=A0reason,=C2=A0also=C2=
=A0in=0D=0A>arch/arm/include/asm/traps.h)=C2=A0and=C2=A0should=C2=A0not=C2=
=A0be=C2=A0duplicated=C2=A0in=0D=0A>include/linux/stacktrace.h.=0D=0A=0D=0A=
Ok,=20done.=0D=0A=0D=0ASending=20new=20patch=20with=20fixes.=0D=0A=0D=0ATha=
nks.=0D=0AManinder=20Singh=0D=0A=0D=0A=0D=0A=0D=0A=C2=A0=0D=0A=C2=A0
