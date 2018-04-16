Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B7B206B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 04:07:45 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p189so9018243pfp.1
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 01:07:45 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id p5-v6si2801778plk.441.2018.04.16.01.07.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 01:07:44 -0700 (PDT)
Received: from epcas5p2.samsung.com (unknown [182.195.41.40])
	by mailout1.samsung.com (KnoxPortal) with ESMTP id 20180416080742epoutp0133f75ae359c86b8ee4d2141b881d8672~l3Bw2azsI3235932359epoutp01O
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:07:42 +0000 (GMT)
Mime-Version: 1.0
Subject: Re: [PATCH v3] mm/page_owner: ignore everything below the IRQ entry
 point
Reply-To: maninder1.s@samsung.com
From: Maninder Singh <maninder1.s@samsung.com>
In-Reply-To: <201803272356.6XjvciDF%fengguang.wu@intel.com>
Message-ID: <20180416054459epcms5p85f343635408abccfd12080d7fc322911@epcms5p8>
Date: Mon, 16 Apr 2018 11:14:59 +0530
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"
References: <201803272356.6XjvciDF%fengguang.wu@intel.com>
	<1522150907-33547-1-git-send-email-maninder1.s@samsung.com>
	<CGME20180327160057epcas5p30597e515a359dc6a5d54767a8bcb78a7@epcms5p8>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "dvyukov@google.com" <dvyukov@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "arnd@arndb.de" <arnd@arndb.de>
Cc: kbuild test robot <lkp@intel.com>, "kbuild-all@01.org" <kbuild-all@01.org>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "glider@google.com" <glider@google.com>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "pombredanne@nexb.com" <pombredanne@nexb.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, "mhocko@suse.com" <mhocko@suse.com>, "vinmenon@codeaurora.org" <vinmenon@codeaurora.org>, "gomonovych@gmail.com" <gomonovych@gmail.com>, Ayush Mittal <ayush.m@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, PANKAJ MISHRA <pankaj.m@samsung.com>, Vaneet Narang <v.narang@samsung.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "jdike@addtoit.com" <jdike@addtoit.com>, "richard@nod.at" <richard@nod.at>, "user-mode-linux-devel@lists.sourceforge.net" <user-mode-linux-devel@lists.sourceforge.net>, "user-mode-linux-user@lists.sourceforge.net" <user-mode-linux-user@lists.sourceforge.net>

=C2=A0=0D=0AHi=20Arnd,=0D=0A=0D=0A=0D=0AWe=20sent=20one=20patch=20for=20ign=
oring=20entries=20below=20IRQ=20point=20in=20page_onwer=20using=20stackdepo=
t.=0D=0A=0D=0AV2:-=20https://lkml.org/lkml/2018/3/26/178=0D=0A=0D=0AV3:-=20=
https://lkml.org/lkml/2018/3/27/357=0D=0A=0D=0ABut=20it's=20breaking=20buil=
d=20for=20um=20target=20with=20below=20reason.=0D=0A=0D=0A=0D=0A=C2=A0=C2=
=A0=C2=A0kernel/stacktrace.o:=C2=A0In=C2=A0function=C2=A0=60filter_irq_stac=
ks':=0D=0A>>=C2=A0stacktrace.c:(.text+0x20e):=C2=A0undefined=C2=A0reference=
=C2=A0to=C2=A0=60__irqentry_text_start'=0D=0A>>=C2=A0stacktrace.c:(.text+0x=
218):=C2=A0undefined=C2=A0reference=C2=A0to=C2=A0=60__irqentry_text_end'=0D=
=0A>>=C2=A0stacktrace.c:(.text+0x222):=C2=A0undefined=C2=A0reference=C2=A0t=
o=C2=A0=60__softirqentry_text_start'=0D=0A>>=C2=A0stacktrace.c:(.text+0x22c=
):=C2=A0undefined=C2=A0reference=C2=A0to=C2=A0=60__softirqentry_text_end'=
=0D=0A=C2=A0=C2=A0=C2=A0collect2:=C2=A0error:=C2=A0ld=C2=A0returned=C2=A01=
=C2=A0exit=C2=A0status=0D=0A=0D=0ASo=20can=20we=20add=20below=20fix=20for=
=20this=20build=20break,=20can=20you=20suggest=20if=20it=20is=20ok=20or=20w=
e=20need=20to=20find=0D=0Asome=20other=20way:-=0D=0A=0D=0Adiff=20--git=20a/=
include/asm-generic/vmlinux.lds.h=20b/include/asm-generic/vmlinux.lds.h=0D=
=0Aindex=2076b63f5..0f3b7f8=20100644=0D=0A---=20a/include/asm-generic/vmlin=
ux.lds.h=0D=0A+++=20b/include/asm-generic/vmlinux.lds.h=0D=0A=40=40=20-460,=
6=20+460,10=20=40=40=0D=0A=20=20*=20to=20use=20=22..=22=20first.=0D=0A=20=
=20*/=0D=0A=20=23define=20TEXT_TEXT=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=5C=0D=0A+=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20VMLINUX_SYMBOL(__irqentry_text_start)=20=3D=
=20.;=20=20=20=20=20=20=20=20=20=20=20=20=20=20=5C=0D=0A+=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20VMLINUX_SYMBOL(__irqentry_text_end)=20=3D=20.;=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=5C=0D=0A+=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20VMLINUX_SYMBOL(__softirqentry_text_start)=20=
=3D=20.;=20=20=20=20=20=20=20=20=20=20=5C=0D=0A+=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20VMLINUX_SYMBOL(__softirqentry_text_end)=20=3D=20.;=20=20=
=20=20=20=20=20=20=20=20=20=20=5C=0D=0A=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20ALIGN_FUNCTION();=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=5C=
=0D=0A=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20*(.text.hot=20TEXT_MA=
IN=20.text.fixup=20.text.unlikely)=20=20=20=20=20=20=20=5C=0D=0A=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20*(.text..refcount)=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=5C=0D=0Adiff=20--git=20a/include/linux/kallsyms.h=20b=
/include/linux/kallsyms.h=0D=0A=0D=0A=0D=0ATo=20make=20solution=20generic=
=20for=20all=20architecture=20we=20declared=204=20dummy=20variables=20which=
=20we=20used=20in=20our=20patch.=0D=0A=0D=0A=0D=0AThanks=20,=0D=0AManinder=
=20Singh
