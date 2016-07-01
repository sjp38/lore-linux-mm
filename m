Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8624C6B0005
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 23:21:16 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id s63so197153879ioi.1
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 20:21:16 -0700 (PDT)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id m15si593792oik.250.2016.06.30.20.21.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 20:21:15 -0700 (PDT)
Received: by mail-oi0-x232.google.com with SMTP id f189so93986018oig.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 20:21:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMzpN2iLBKF7vK3TuTPwYn2nZOw2q_Pn=q+g6pNuVs0k6Xd5LQ@mail.gmail.com>
References: <20160701001209.7DA24D1C@viggo.jf.intel.com>
	<20160701001218.3D316260@viggo.jf.intel.com>
	<CA+55aFwm74uiqwsV5dvVMDBAthwmHub3J3Wz9cso0PpgVTHUPA@mail.gmail.com>
	<CAMzpN2iLBKF7vK3TuTPwYn2nZOw2q_Pn=q+g6pNuVs0k6Xd5LQ@mail.gmail.com>
Date: Thu, 30 Jun 2016 20:21:15 -0700
Message-ID: <CA+55aFwVMHWH=Xiu7o8RXNgSQ6C6==RZhMNoWJ=kMwA5LAQXdg@mail.gmail.com>
Subject: Re: [PATCH 6/6] x86: Fix stray A/D bit setting into non-present PTEs
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/alternative; boundary=001a113defaab627c405368a7ad3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, linux-mm <linux-mm@kvack.org>, Dave Hansen <dave@sr71.net>

--001a113defaab627c405368a7ad3
Content-Type: text/plain; charset=UTF-8

On Jun 30, 2016 8:06 PM, "Brian Gerst" <brgerst@gmail.com> wrote:
>
> Could this affect a 32-bit guest VM?

Even on 32-bit, all the distros do PAE to get NX and access to more
physical memory, and that has a 64-bit page table entry.

The 32-bit page table case is pretty unusual.

     Linus

--001a113defaab627c405368a7ad3
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On Jun 30, 2016 8:06 PM, &quot;Brian Gerst&quot; &lt;<a href=3D"mailto:brge=
rst@gmail.com">brgerst@gmail.com</a>&gt; wrote:<br>
&gt;<br>
&gt; Could this affect a 32-bit guest VM?</p>
<p dir=3D"ltr">Even on 32-bit, all the distros do PAE to get NX and access =
to more physical memory, and that has a 64-bit page table entry.</p>
<p dir=3D"ltr">The 32-bit page table case is pretty unusual.</p>
<p dir=3D"ltr">=C2=A0=C2=A0=C2=A0=C2=A0 Linus</p>

--001a113defaab627c405368a7ad3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
