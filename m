Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB446B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 12:36:40 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id c18so1319668vkd.17
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 09:36:40 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i129sor4517150vkd.219.2017.11.06.09.36.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 09:36:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CACAwPwY5ss_D9kj7XoLVVkQ9=KXDFCnyDzdoxkGxhJZBNFre3w@mail.gmail.com>
References: <CACAwPwY0owut+314c5sy7jNViZqfrKy3sSf1hjLTocXefrz3xA@mail.gmail.com>
 <20171106130507.bm75uclqqoniqwdv@dhcp22.suse.cz> <CACAwPwZHH+TLov0hwYN-KWYowzk3yycj__GCfKH1MehPmuJ+Ow@mail.gmail.com>
 <20171106171150.7a2lent6vdrewsk7@dhcp22.suse.cz> <CACAwPwZuiT9BfunVgy73KYjGfVopgcE0dknAxSLPNeJB8rkcMQ@mail.gmail.com>
 <CACAwPwZqFRyFJhb7pyyrufah+1TfCDuzQMo3qwJuMKkp6aYd_Q@mail.gmail.com>
 <CACAwPwbA0NpTC9bfV7ySHkxPrbZJVvjH=Be5_c25Q3S8qNay+w@mail.gmail.com>
 <CACAwPwamD4RL9O8wujK_jCKGu=x0dBBmH9O-9078cUEEk4WsMA@mail.gmail.com>
 <CACAwPwYKjK5RT-ChQqqUnD7PrtpXg1WhTHGK3q60i6StvDMDRg@mail.gmail.com>
 <CACAwPwav-eY4_nt=Z7TQB8WMFg+1X5WY2Gkgxph74X7=Ovfvrw@mail.gmail.com>
 <CACAwPwaP05FgxTp=kavwgFZF+LEGO-OSspJ4jH+Y=_uRxiVZaA@mail.gmail.com> <CACAwPwY5ss_D9kj7XoLVVkQ9=KXDFCnyDzdoxkGxhJZBNFre3w@mail.gmail.com>
From: Maxim Levitsky <maximlevitsky@gmail.com>
Date: Mon, 6 Nov 2017 19:36:38 +0200
Message-ID: <CACAwPwYp4TysdH_1w1F9L7BpwFAGR8dNg04F6QASyQeYYNErkg@mail.gmail.com>
Subject: Re: Guaranteed allocation of huge pages (1G) using movablecore=N
 doesn't seem to work at all
Content-Type: multipart/alternative; boundary="001a114416d496e608055d53e595"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

--001a114416d496e608055d53e595
Content-Type: text/plain; charset="UTF-8"

Isn't this a non backward compatible change? Why to remove an optional non
default option for use cases like mine.
I won't argue with you on this, but my question was different, and was why
the kernel can't move other pages from moveable zone in my case.

PS: removed LKML from the CC because I am on mobile and that shit gmail
client sends only html mail. Sorry for that.

Best regards,
      Maxim Levitsky

--001a114416d496e608055d53e595
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto">Isn&#39;t this a non backward compatible change? Why to r=
emove an optional non default option for use cases like mine.<div dir=3D"au=
to">I won&#39;t argue with you on this, but my question was different, and =
was why the kernel can&#39;t move other pages from moveable zone in my case=
.</div><div dir=3D"auto"><br></div><div dir=3D"auto">PS: removed LKML from =
the CC because I am on mobile and that shit gmail client sends only html ma=
il. Sorry for that.</div><div dir=3D"auto"><br></div><div dir=3D"auto">Best=
 regards,</div><div dir=3D"auto">=C2=A0 =C2=A0 =C2=A0 Maxim Levitsky</div><=
/div>

--001a114416d496e608055d53e595--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
