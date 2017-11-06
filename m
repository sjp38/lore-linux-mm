Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 397A16B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 13:13:39 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id k123so4910942vkb.18
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 10:13:39 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w124sor4580674vka.256.2017.11.06.10.13.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 10:13:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171106180406.diowlwanvucnwkbp@dhcp22.suse.cz>
References: <20171106171150.7a2lent6vdrewsk7@dhcp22.suse.cz>
 <CACAwPwZuiT9BfunVgy73KYjGfVopgcE0dknAxSLPNeJB8rkcMQ@mail.gmail.com>
 <CACAwPwZqFRyFJhb7pyyrufah+1TfCDuzQMo3qwJuMKkp6aYd_Q@mail.gmail.com>
 <CACAwPwbA0NpTC9bfV7ySHkxPrbZJVvjH=Be5_c25Q3S8qNay+w@mail.gmail.com>
 <CACAwPwamD4RL9O8wujK_jCKGu=x0dBBmH9O-9078cUEEk4WsMA@mail.gmail.com>
 <CACAwPwYKjK5RT-ChQqqUnD7PrtpXg1WhTHGK3q60i6StvDMDRg@mail.gmail.com>
 <CACAwPwav-eY4_nt=Z7TQB8WMFg+1X5WY2Gkgxph74X7=Ovfvrw@mail.gmail.com>
 <CACAwPwaP05FgxTp=kavwgFZF+LEGO-OSspJ4jH+Y=_uRxiVZaA@mail.gmail.com>
 <CACAwPwY5ss_D9kj7XoLVVkQ9=KXDFCnyDzdoxkGxhJZBNFre3w@mail.gmail.com>
 <CACAwPwYp4TysdH_1w1F9L7BpwFAGR8dNg04F6QASyQeYYNErkg@mail.gmail.com> <20171106180406.diowlwanvucnwkbp@dhcp22.suse.cz>
From: Maxim Levitsky <maximlevitsky@gmail.com>
Date: Mon, 6 Nov 2017 20:13:36 +0200
Message-ID: <CACAwPwaTejMB8yOrkOxpDj297B=Y6bTvw2nAyHsiJKC+aB=a2w@mail.gmail.com>
Subject: Re: Guaranteed allocation of huge pages (1G) using movablecore=N
 doesn't seem to work at all
Content-Type: multipart/alternative; boundary="001a11457176d4205f055d5469fe"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

--001a11457176d4205f055d5469fe
Content-Type: text/plain; charset="UTF-8"

Yes, I tested git head from mainline and few kernels from ubuntu repos
since I was lazy to compile them too.

Do you have an idea what can I do about this issue? Do you think its
feasable to fix this?

And if not using moveable zone, how would it even be possible to have
guaranreed allocation of 1g pages

I do know some kernel programming (I contributed some drivers for my
laptop) so I could help if you have a direction for me to take.

Best regards,
      Maxim Levitsky

--001a11457176d4205f055d5469fe
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><br><div class=3D"gmail_extra" dir=3D"auto"><div class=3D=
"gmail_quote">Yes, I tested git head from mainline and few kernels from ubu=
ntu repos since I was lazy to compile them too.</div><div class=3D"gmail_qu=
ote" dir=3D"auto"><br></div><div class=3D"gmail_quote" dir=3D"auto">Do you =
have an idea what can I do about this issue? Do you think its feasable to f=
ix this?=C2=A0</div><div class=3D"gmail_quote" dir=3D"auto"><br></div><div =
class=3D"gmail_quote" dir=3D"auto">And if not using moveable zone, how woul=
d it even be possible to have guaranreed allocation of 1g pages</div><div c=
lass=3D"gmail_quote" dir=3D"auto"><br></div><div class=3D"gmail_quote" dir=
=3D"auto">I do know some kernel programming (I contributed some drivers for=
 my laptop) so I could help if you have a direction for me to take.</div><d=
iv class=3D"gmail_quote" dir=3D"auto"><br></div><div class=3D"gmail_quote" =
dir=3D"auto">Best regards,</div><div class=3D"gmail_quote" dir=3D"auto">=C2=
=A0 =C2=A0 =C2=A0 Maxim Levitsky</div></div></div>

--001a11457176d4205f055d5469fe--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
