Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 108666B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 13:33:28 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id l82so15348862ywc.1
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 10:33:28 -0700 (PDT)
Received: from mail-yw0-x236.google.com (mail-yw0-x236.google.com. [2607:f8b0:4002:c05::236])
        by mx.google.com with ESMTPS id 203si1377827ywp.104.2017.08.07.10.33.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 10:33:27 -0700 (PDT)
Received: by mail-yw0-x236.google.com with SMTP id u207so6940931ywc.3
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 10:33:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
References: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
From: Kostya Serebryany <kcc@google.com>
Date: Mon, 7 Aug 2017 10:33:26 -0700
Message-ID: <CAN=P9pj4tukqbrGwCz6mOyJJS+53EBPJwLTWA3LuP+5qfk+ZMQ@mail.gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
Content-Type: multipart/alternative; boundary="089e0828d3fc91845205562d3ea6"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Kees Cook <keescook@google.com>, danielmicay@gmail.com, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>, Jakub Jelinek <jakub@redhat.com>

--089e0828d3fc91845205562d3ea6
Content-Type: text/plain; charset="UTF-8"

+Jakub Jelinek, who helped us migrate asan's shadow from high addresses
to 0x7fff7000 for a significant ~5% performance and code size gain.
(a few years ago)

--kcc

On Mon, Aug 7, 2017 at 10:24 AM, Dmitry Vyukov <dvyukov@google.com> wrote:

> Hello,
>
> The recent "binfmt_elf: use ELF_ET_DYN_BASE only for PIE" patch:
> https://github.com/torvalds/linux/commit/eab09532d40090698b05a07c1c87f3
> 9fdbc5fab5
> breaks user-space AddressSanitizer. AddressSanitizer makes assumptions
> about address space layout for substantial performance gains. There
> are multiple people complaining about this already:
> https://github.com/google/sanitizers/issues/837
> https://twitter.com/kayseesee/status/894594085608013825
> https://bugzilla.kernel.org/show_bug.cgi?id=196537
> AddressSanitizer maps shadow memory at [0x00007fff7000-0x10007fff7fff]
> expecting that non-pie binaries will be below 2GB and pie
> binaries/modules will be at 0x55 or 0x7f. This is not the first time
> kernel address space shuffling breaks sanitizers. The last one was the
> move to 0x55.
>
> Is it possible to make this change less aggressive and keep the
> executable under 2GB?
>
> In future please be mindful of user-space sanitizers and talk to
> address-sanitizer@googlegroups.com before shuffling address space.
>
> Thanks
>

--089e0828d3fc91845205562d3ea6
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>+Jakub Jelinek, who helped us migrate asan&#39;s shad=
ow from high addresses<br></div><div>to 0x<span style=3D"font-size:12.8px">=
7fff7000 for a significant ~5% performance and code size gain.</span><br><d=
iv><span style=3D"font-size:12.8px">(a few years ago)</span></div></div><di=
v class=3D"gmail_extra"><br></div><div class=3D"gmail_extra">--kcc=C2=A0</d=
iv><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">On Mon, Aug 7,=
 2017 at 10:24 AM, Dmitry Vyukov <span dir=3D"ltr">&lt;<a href=3D"mailto:dv=
yukov@google.com" target=3D"_blank">dvyukov@google.com</a>&gt;</span> wrote=
:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-le=
ft:1px #ccc solid;padding-left:1ex">Hello,<br>
<br>
The recent &quot;binfmt_elf: use ELF_ET_DYN_BASE only for PIE&quot; patch:<=
br>
<a href=3D"https://github.com/torvalds/linux/commit/eab09532d40090698b05a07=
c1c87f39fdbc5fab5" rel=3D"noreferrer" target=3D"_blank">https://github.com/=
torvalds/<wbr>linux/commit/<wbr>eab09532d40090698b05a07c1c87f3<wbr>9fdbc5fa=
b5</a><br>
breaks user-space AddressSanitizer. AddressSanitizer makes assumptions<br>
about address space layout for substantial performance gains. There<br>
are multiple people complaining about this already:<br>
<a href=3D"https://github.com/google/sanitizers/issues/837" rel=3D"noreferr=
er" target=3D"_blank">https://github.com/google/<wbr>sanitizers/issues/837<=
/a><br>
<a href=3D"https://twitter.com/kayseesee/status/894594085608013825" rel=3D"=
noreferrer" target=3D"_blank">https://twitter.com/kayseesee/<wbr>status/894=
594085608013825</a><br>
<a href=3D"https://bugzilla.kernel.org/show_bug.cgi?id=3D196537" rel=3D"nor=
eferrer" target=3D"_blank">https://bugzilla.kernel.org/<wbr>show_bug.cgi?id=
=3D196537</a><br>
AddressSanitizer maps shadow memory at [0x00007fff7000-<wbr>0x10007fff7fff]=
<br>
expecting that non-pie binaries will be below 2GB and pie<br>
binaries/modules will be at 0x55 or 0x7f. This is not the first time<br>
kernel address space shuffling breaks sanitizers. The last one was the<br>
move to 0x55.<br>
<br>
Is it possible to make this change less aggressive and keep the<br>
executable under 2GB?<br>
<br>
In future please be mindful of user-space sanitizers and talk to<br>
<a href=3D"mailto:address-sanitizer@googlegroups.com">address-sanitizer@<wb=
r>googlegroups.com</a> before shuffling address space.<br>
<br>
Thanks<br>
</blockquote></div><br></div></div>

--089e0828d3fc91845205562d3ea6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
