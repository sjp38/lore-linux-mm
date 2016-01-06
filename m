Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 091D16B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 04:17:58 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id mw1so29175678igb.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 01:17:58 -0800 (PST)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id m5si12076957igx.20.2016.01.06.01.17.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 01:17:57 -0800 (PST)
Received: by mail-io0-x22b.google.com with SMTP id 1so166041336ion.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 01:17:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1452056549-10048-2-git-send-email-mguzik@redhat.com>
References: <1452056549-10048-1-git-send-email-mguzik@redhat.com>
	<1452056549-10048-2-git-send-email-mguzik@redhat.com>
Date: Wed, 6 Jan 2016 14:47:57 +0530
Message-ID: <CAKeScWhEHY_kk4NXDTce1uz=W3deAHJ0YOH9X_sJk6A4KjeNUQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] prctl: take mmap sem for writing to protect against others
From: Anshuman Khandual <anshuman.linux@gmail.com>
Content-Type: multipart/alternative; boundary=001a1141d9426f34a10528a6d487
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mateusz Guzik <mguzik@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexey Dobriyan <adobriyan@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jarod Wilson <jarod@redhat.com>, Jan Stancek <jstancek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

--001a1141d9426f34a10528a6d487
Content-Type: text/plain; charset=UTF-8

On Wed, Jan 6, 2016 at 10:32 AM, Mateusz Guzik <mguzik@redhat.com> wrote:

> The code was taking the semaphore for reading, which does not protect
> against readers nor concurrent modifications.
>
>
(down/up)_read does not protect against concurrent readers ?


> The problem could cause a sanity checks to fail in procfs's cmdline
> reader, resulting in an OOPS.
>

Can you explain this a bit and may be give some examples ?


>
> Note that some functions perform an unlocked read of various mm fields,
> but they seem to be fine despite possible modificaton.
>
>
Those need to be fixed as well ?


> Signed-off-by: Mateusz Guzik <mguzik@redhat.com>
>

--001a1141d9426f34a10528a6d487
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">=
On Wed, Jan 6, 2016 at 10:32 AM, Mateusz Guzik <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:mguzik@redhat.com" target=3D"_blank">mguzik@redhat.com</a>&gt;<=
/span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8=
ex;border-left:1px #ccc solid;padding-left:1ex">The code was taking the sem=
aphore for reading, which does not protect<br>
against readers nor concurrent modifications.<br>
<br></blockquote><div><br>(down/up)_read does not protect against concurren=
t readers ?<br>=C2=A0<br></div><blockquote class=3D"gmail_quote" style=3D"m=
argin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
The problem could cause a sanity checks to fail in procfs&#39;s cmdline<br>
reader, resulting in an OOPS.<br></blockquote><div><br></div><div>Can you e=
xplain this a bit and may be give some examples ?<br>=C2=A0<br></div><block=
quote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc=
 solid;padding-left:1ex">
<br>
Note that some functions perform an unlocked read of various mm fields,<br>
but they seem to be fine despite possible modificaton.<br>
<br></blockquote><br></div><div class=3D"gmail_quote">Those need to be fixe=
d as well ?<br>=C2=A0<br></div><div class=3D"gmail_quote"><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">
Signed-off-by: Mateusz Guzik &lt;<a href=3D"mailto:mguzik@redhat.com">mguzi=
k@redhat.com</a>&gt;<br></blockquote></div><br></div></div>

--001a1141d9426f34a10528a6d487--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
