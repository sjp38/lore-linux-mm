Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id E65556B0253
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 20:39:19 -0400 (EDT)
Received: by oigi138 with SMTP id i138so14268860oig.2
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 17:39:19 -0700 (PDT)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id m17si23807791obe.74.2015.10.08.17.39.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 17:39:19 -0700 (PDT)
Received: by oibi136 with SMTP id i136so36430715oib.3
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 17:39:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BA6F50564D52C24884F9840E07E32DEC2A90B9D9@CDSMSX102.ccr.corp.intel.com>
References: <BA6F50564D52C24884F9840E07E32DEC2A90B9D9@CDSMSX102.ccr.corp.intel.com>
Date: Fri, 9 Oct 2015 08:39:19 +0800
Message-ID: <CAF7GXvov1FGezb3SFzBcLy6XAQc6X7a8pm+BFYjN2sZmQka_vA@mail.gmail.com>
Subject: Re: about kmemcheck on Linux-3.14
From: "Figo.zhang" <figo1802@gmail.com>
Content-Type: multipart/alternative; boundary=001a113adee6c69b5e0521a135ff
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Zhang, Tianfei" <tianfei.zhang@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>, "Xiao, Guangrong" <guangrong.xiao@intel.com>

--001a113adee6c69b5e0521a135ff
Content-Type: text/plain; charset=UTF-8

2015-09-25 12:15 GMT+08:00 Zhang, Tianfei <tianfei.zhang@intel.com>:

> Hi all:
>
>
>
> I am using linux-3.14 on Android device, want to use kmemcheck.
>
>
>
> I write a sample test module, it seems the kmemcheck and slub_debug cannot
> detect it, any suggestion?
>
>
>
>
>
it seems some problem on Kmemcheck?

--001a113adee6c69b5e0521a135ff
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">2015-09-25 12:15 GMT+08:00 Zhang, Tianfei <span dir=3D"ltr">&lt;<a href=
=3D"mailto:tianfei.zhang@intel.com" target=3D"_blank">tianfei.zhang@intel.c=
om</a>&gt;</span>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0=
 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">





<div lang=3D"ZH-CN" link=3D"#0563C1" vlink=3D"#954F72">
<div>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:12.0pt">Hi a=
ll:<u></u><u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:12.0pt"><u><=
/u>=C2=A0<u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:12.0pt">I am=
 using linux-3.14 on Android device, want to use kmemcheck.<u></u><u></u></=
span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:12.0pt"><u><=
/u>=C2=A0<u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:12.0pt">I wr=
ite a sample test module, it seems the kmemcheck and slub_debug cannot dete=
ct it, any suggestion?<u></u><u></u></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:12.0pt"><u><=
/u>=C2=A0<u></u></span></p>
<p class=3D"MsoNormal"><br></p></div></div></blockquote><div><br></div><div=
>it seems some problem on Kmemcheck?=C2=A0</div></div></div></div>

--001a113adee6c69b5e0521a135ff--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
