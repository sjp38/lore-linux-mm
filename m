Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CBEF26B0047
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 11:01:08 -0500 (EST)
Received: by ghrr17 with SMTP id r17so1013272ghr.14
        for <linux-mm@kvack.org>; Wed, 30 Nov 2011 08:01:06 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 30 Nov 2011 10:01:05 -0600
Message-ID: <CAB7xdiknXNrNA6Yczr6h0b8w4Smz1k86jm3POqecOdfVFu7kGA@mail.gmail.com>
Subject: about memory zone
From: sheng qiu <herbert1984106@gmail.com>
Content-Type: multipart/alternative; boundary=e89a8f83ab8be6d52504b2f5d71f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--e89a8f83ab8be6d52504b2f5d71f
Content-Type: text/plain; charset=ISO-8859-1

Hi everyone,

i am doing some research work that need to utilize the swapping stuff of
linux kernel. i add one separate zone, which only used for my application,
i prevent the other application or kernel from allocating from that zone. i
marked every page that allocated form my zone with reclaimable flag. but
when my zone is nearly full, which will trigger the kswapd to swap out some
pages, the balance_pgdat found the reclaimable pages inside my zone is 0.
because the NR_INACTIVE_FILE, NR_ACTIVE_FILE, NR_INACTIVE_ANON,
NR_ACTIVE_ANON lru list are all empty. i do not know why kernel did not do
any statistics on my own zone.

Does anyone know why this happen? and how to solve this? i need swapping
support on my own zone too.

Thanks,
Sheng

-- 
Sheng Qiu
Texas A & M University
Room 302 Wisenbaker
email: herbert1984106@gmail.com
College Station, TX 77843-3259

--e89a8f83ab8be6d52504b2f5d71f
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi everyone,<br><br>i am doing some research work that need to utilize=20
the swapping stuff of linux kernel. i add one separate zone, which only=20
used for my application, i prevent the other application or kernel from=20
allocating from that zone. i marked every page that allocated form my=20
zone with reclaimable flag. but when my zone is nearly full, which will=20
trigger the kswapd to swap out some pages, the balance_pgdat found the=20
reclaimable pages inside my zone is 0.=A0 because the NR_INACTIVE_FILE,=20
NR_ACTIVE_FILE, NR_INACTIVE_ANON, NR_ACTIVE_ANON lru list are all empty.
 i do not know why kernel did not do any statistics on my own zone. <br>
<br>Does anyone know why this happen? and how to solve this? i need swappin=
g support on my own zone too.<br><br>Thanks,<br>Sheng<br clear=3D"all"><br>=
-- <br>Sheng Qiu<br>Texas A &amp; M University<br>Room 302 Wisenbaker=A0 =
=A0 <br>

email: <a href=3D"mailto:herbert1984106@gmail.com" target=3D"_blank">herber=
t1984106@gmail.com</a><br>College Station, TX 77843-3259<br>

--e89a8f83ab8be6d52504b2f5d71f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
