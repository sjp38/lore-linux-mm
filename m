Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id F1F5B6B02E7
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 19:16:27 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id v73so74808740ywg.2
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 16:16:27 -0800 (PST)
Received: from mail-yb0-x243.google.com (mail-yb0-x243.google.com. [2607:f8b0:4002:c09::243])
        by mx.google.com with ESMTPS id 140si1483803ywg.92.2017.01.19.16.16.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 16:16:27 -0800 (PST)
Received: by mail-yb0-x243.google.com with SMTP id p3so5156674yba.2
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 16:16:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170119155701.GA24654@leverpostej>
References: <20170119145114.GA19772@pjb1027-Latitude-E5410> <20170119155701.GA24654@leverpostej>
From: park jinbum <jinb.park7@gmail.com>
Date: Fri, 20 Jan 2017 09:16:26 +0900
Message-ID: <CAErMHp_YFRnfruLKWnzyg9ZcfYdbLy9xU905GoWYGFRO32T_Wg@mail.gmail.com>
Subject: Re: [PATCH] mm: add arch-independent testcases for RODATA
Content-Type: multipart/alternative; boundary=001a113f1416918aeb05467b8fdd
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: hpa@zytor.com, x86@kernel.org, akpm@linuxfoundation.org, keescook@chromium.org, linux-mm@kvack.org, arjan@linux.intel.com, mingo@redhat.com, tglx@linutronix.de, linux@armlinux.org.uk, kernel-janitors@vger.kernel.org, kernel-hardening@lists.openwall.com, labbott@redhat.com, linux-kernel@vger.kernel.org

--001a113f1416918aeb05467b8fdd
Content-Type: text/plain; charset=UTF-8

1) make the test use put_user()
2) move the rodata_test() call and the prototype to a common location
3) move the test out to mm/ (with no changes to file itself)


Where is the best place for common test file in general??

 kernel/rodata_test.c
 include/rodata_test.h => Is it fine??

I can't see common file about rodata.
So I'm confused where the best place is.

--001a113f1416918aeb05467b8fdd
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><div class=3D"gmail_extra"><div class=3D"gmail_quote=
"><br></div></div></div><div dir=3D"auto"><br></div><div dir=3D"auto"><div =
class=3D"gmail_extra"><div class=3D"gmail_quote"><blockquote class=3D"m_-10=
59893792884121468m_649618024736465831quote" style=3D"margin:0 0 0 .8ex;bord=
er-left:1px #ccc solid;padding-left:1ex">
1) make the test use put_user()<br>
2) move the rodata_test() call and the prototype to a common location<br>
3) move the test out to mm/ (with no changes to file itself)</blockquote></=
div></div></div><div dir=3D"auto"><br></div><div dir=3D"auto">Where is the =
best place for common test file in general??</div><div dir=3D"auto"><br></d=
iv><div dir=3D"auto"></div><div dir=3D"auto">=C2=A0kernel/rodata_test.c=C2=
=A0</div><div dir=3D"auto">=C2=A0include/rodata_test.h =3D&gt; Is it fine??=
</div><div dir=3D"auto"><br></div><div dir=3D"auto">I can&#39;t see common =
file about rodata.</div><div dir=3D"auto">So I&#39;m confused where the bes=
t place is.</div><div dir=3D"auto"><br></div><div dir=3D"auto"><br></div><d=
iv dir=3D"auto"><br></div><div dir=3D"auto"></div></div>

--001a113f1416918aeb05467b8fdd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
