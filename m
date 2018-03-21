Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D5BD86B0025
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 13:07:51 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v131so2583565wmv.6
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 10:07:51 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b83sor1440244wme.4.2018.03.21.10.07.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Mar 2018 10:07:50 -0700 (PDT)
MIME-Version: 1.0
References: <alpine.DEB.2.20.1803171208370.21003@alpaca> <CACT4Y+aLqY6wUfRMto_CZxPRSyvPKxK8ucvAmAY-aR_gq8fOAg@mail.gmail.com>
 <20180319172902.GB37438@google.com> <CACT4Y+Z9xeWvu5XUy_qNTewihuCC1-2a0hZDuymU6PA_3NJ90Q@mail.gmail.com>
 <20180319175457.GC37438@google.com> <CACT4Y+ZsmWyvfcpCtxEUH3YJDDNFUAO=0kyCmJAfv=NXeVGRkA@mail.gmail.com>
In-Reply-To: <CACT4Y+ZsmWyvfcpCtxEUH3YJDDNFUAO=0kyCmJAfv=NXeVGRkA@mail.gmail.com>
From: Nick Desaulniers <ndesaulniers@google.com>
Date: Wed, 21 Mar 2018 17:07:38 +0000
Message-ID: <CAKwvOd=S=ZqtfWM9RqYN9d_tUeHqhPFyEJoz4jBgXwYBvYJ3DA@mail.gmail.com>
Subject: Re: clang fails on linux-next since commit 8bf705d13039
Content-Type: multipart/alternative; boundary="001a11422ca415cc040567ef3b09"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Matthias Kaehlcke <mka@chromium.org>, lukas.bulwahn@gmail.com, Greg Hackmann <ghackmann@google.com>, Luis Lozano <llozano@google.com>, Michael Davidson <md@google.com>, Sami Tolvanen <samitolvanen@google.com>, Paul Lawrence <paullawrence@google.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, kasan-dev <kasan-dev@googlegroups.com>, llvmlinux@lists.linuxfoundation.org, sil2review@lists.osadl.org, manojgupta@chromium.org, Stephen Hines <srhines@google.com>

--001a11422ca415cc040567ef3b09
Content-Type: text/plain; charset="UTF-8"

On Mon, Mar 19, 2018 at 11:16 AM Dmitry Vyukov <dvyukov@google.com> wrote:

> This looks like something that will hit us again and again if we don't
> fix this in clang.
>

I agree.  I'll bring it up with some our coworkers who hack on the
integrated assembler.

-- 
Thanks,
~Nick Desaulniers

--001a11422ca415cc040567ef3b09
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_quote"><div dir=3D"ltr">On Mon, Mar 19=
, 2018 at 11:16 AM Dmitry Vyukov &lt;<a href=3D"mailto:dvyukov@google.com">=
dvyukov@google.com</a>&gt; wrote:</div><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
This looks like something that will hit us again and again if we don&#39;t<=
br>
fix this in clang.<br>
</blockquote></div><br clear=3D"all"><div><span style=3D"color:rgb(34,34,34=
);font-family:sans-serif;font-size:13px;font-style:normal;font-variant-liga=
tures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:normal=
;text-align:start;text-indent:0px;text-transform:none;white-space:normal;wo=
rd-spacing:0px;background-color:rgb(255,255,255);text-decoration-style:init=
ial;text-decoration-color:initial;float:none;display:inline">I agree.=C2=A0=
 I&#39;ll bring it up with some our coworkers who hack on the integrated as=
sembler.</span><br style=3D"color:rgb(34,34,34);font-family:sans-serif;font=
-size:13px;font-style:normal;font-variant-ligatures:normal;font-variant-cap=
s:normal;font-weight:400;letter-spacing:normal;text-align:start;text-indent=
:0px;text-transform:none;white-space:normal;word-spacing:0px;text-decoratio=
n-style:initial;text-decoration-color:initial"><br></div>-- <br><div dir=3D=
"ltr" class=3D"gmail_signature" data-smartmail=3D"gmail_signature"><div dir=
=3D"ltr">Thanks,<div>~Nick Desaulniers</div></div></div></div>

--001a11422ca415cc040567ef3b09--
