Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2178A6B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 12:03:11 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id m133so3936525vkd.3
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 09:03:11 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e17sor343481vke.70.2017.11.06.09.03.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 09:03:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171106130507.bm75uclqqoniqwdv@dhcp22.suse.cz>
References: <CACAwPwY0owut+314c5sy7jNViZqfrKy3sSf1hjLTocXefrz3xA@mail.gmail.com>
 <20171106130507.bm75uclqqoniqwdv@dhcp22.suse.cz>
From: Maxim Levitsky <maximlevitsky@gmail.com>
Date: Mon, 6 Nov 2017 19:03:08 +0200
Message-ID: <CACAwPwZHH+TLov0hwYN-KWYowzk3yycj__GCfKH1MehPmuJ+Ow@mail.gmail.com>
Subject: Re: Guaranteed allocation of huge pages (1G) using movablecore=N
 doesn't seem to work at all
Content-Type: multipart/alternative; boundary="001a11438adccd48e1055d536d25"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

--001a11438adccd48e1055d536d25
Content-Type: text/plain; charset="UTF-8"

I am fully aware of this.
This is why we have /proc/vm/treat_hugepages_as_moveable which I did set.
Did you remove this option?

I don't need/have memory hotplug so I am ok with huge pages beeing not
movable in the movable zone.
The idea here is that other pages in that zone should be moveable so I
should be able to move all of them outside and replace them with hugepages.
This clearly doesn't work here so thats why I am asking my question

Best regards,
    Maxim Levitsky

--001a11438adccd48e1055d536d25
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto">I am fully aware of this.<div dir=3D"auto">This is why we=
 have /proc/vm/treat_hugepages_as_moveable which I did set. Did you remove =
this option?</div><div dir=3D"auto"><br></div><div dir=3D"auto">I don&#39;t=
 need/have memory hotplug so I am ok with huge pages beeing not movable in =
the movable zone.</div><div dir=3D"auto">The idea here is that other pages =
in that zone should be moveable so I should be able to move all of them out=
side and replace them with hugepages. This clearly doesn&#39;t work here so=
 thats why I am asking my question</div><div dir=3D"auto"><br></div><div di=
r=3D"auto">Best regards,</div><div dir=3D"auto">=C2=A0 =C2=A0 Maxim Levitsk=
y</div><div dir=3D"auto"><br></div><div class=3D"gmail_extra" dir=3D"auto">=
<div class=3D"gmail_quote"><br></div></div></div>

--001a11438adccd48e1055d536d25--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
