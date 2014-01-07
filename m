Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f51.google.com (mail-qe0-f51.google.com [209.85.128.51])
	by kanga.kvack.org (Postfix) with ESMTP id EAE976B0035
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 20:37:02 -0500 (EST)
Received: by mail-qe0-f51.google.com with SMTP id 1so19772538qee.10
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 17:37:02 -0800 (PST)
Received: from mail-qe0-x22b.google.com (mail-qe0-x22b.google.com [2607:f8b0:400d:c02::22b])
        by mx.google.com with ESMTPS id e9si26565910qar.4.2014.01.06.17.37.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 17:37:01 -0800 (PST)
Received: by mail-qe0-f43.google.com with SMTP id jy17so19018999qeb.16
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 17:37:01 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 7 Jan 2014 09:37:01 +0800
Message-ID: <CANwX7LTkb3v6Aq9nqFWN-cykX08+fuAntFMDRu7DM_pcyK9iSw@mail.gmail.com>
Subject: [Help] Question about vm: fair zone allocator policy
From: yvxiang <linyvxiang@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b6773a0b0e08104ef576934
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: linux-mm@kvack.org

--047d7b6773a0b0e08104ef576934
Content-Type: text/plain; charset=ISO-8859-1

Hi, Johannes

     I'm a new comer to vm. And I read your commit 81c0a2bb about fair zone
allocator policy,  but I don't quite understand your opinion, especially
the words that

   "the allocator may keep kswapd running while kswapd reclaim
    ensures that the page allocator can keep allocating from the first zone
in
    the zonelist for extended periods of time. "

    Could you or someone else explain me what does this mean in more
details? Or could you give me a example?

    Thank you very much!!

--047d7b6773a0b0e08104ef576934
Content-Type: text/html; charset=GB2312
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi,&nbsp;<span style=3D"color:rgb(0,0,0);font-family:=CE=
=A2=C8=ED=D1=C5=BA=DA;font-size:14px">Johannes&nbsp;</span><div><span style=
=3D"color:rgb(0,0,0);font-family:=CE=A2=C8=ED=D1=C5=BA=DA;font-size:14px">&=
nbsp; &nbsp;&nbsp;</span></div><div><span style=3D"color:rgb(0,0,0);font-fa=
mily:=CE=A2=C8=ED=D1=C5=BA=DA;font-size:14px">&nbsp; &nbsp; &nbsp;I&#39;m a=
 new comer to vm. And I read your commit&nbsp;</span><span style=3D"color:r=
gb(0,0,0);font-family:=CE=A2=C8=ED=D1=C5=BA=DA;font-size:14px">81c0a2bb abo=
ut fair zone allocator policy, &nbsp;but I don&#39;t quite understand your =
opinion, especially the words that</span></div>
<div><span style=3D"color:rgb(0,0,0);font-family:=CE=A2=C8=ED=D1=C5=BA=DA;f=
ont-size:14px">&nbsp;</span></div><div><span style=3D"color:rgb(0,0,0);font=
-family:=CE=A2=C8=ED=D1=C5=BA=DA;font-size:14px">&nbsp; &nbsp;&quot;</span>=
<span style=3D"color:rgb(0,0,0);font-family:=CE=A2=C8=ED=D1=C5=BA=DA;font-s=
ize:14px">the allocator may keep kswapd running while kswapd reclaim</span>=
</div>
<div style=3D"color:rgb(0,0,0);font-family:=CE=A2=C8=ED=D1=C5=BA=DA;font-si=
ze:14px">&nbsp; &nbsp; ensures that the page allocator can keep allocating =
from the first zone in</div><div style=3D"color:rgb(0,0,0);font-family:=CE=
=A2=C8=ED=D1=C5=BA=DA;font-size:14px">&nbsp; &nbsp; the zonelist for extend=
ed periods of time. &quot;</div>
<div style=3D"color:rgb(0,0,0);font-family:=CE=A2=C8=ED=D1=C5=BA=DA;font-si=
ze:14px"><br></div><div style=3D"color:rgb(0,0,0);font-family:=CE=A2=C8=ED=
=D1=C5=BA=DA;font-size:14px">&nbsp; &nbsp; Could you or someone else explai=
n me what does this mean in more details? Or could you give me a example?</=
div>
<div style=3D"color:rgb(0,0,0);font-family:=CE=A2=C8=ED=D1=C5=BA=DA;font-si=
ze:14px"><br></div><div style=3D"color:rgb(0,0,0);font-family:=CE=A2=C8=ED=
=D1=C5=BA=DA;font-size:14px">&nbsp; &nbsp; Thank you very much!!</div></div=
>

--047d7b6773a0b0e08104ef576934--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
