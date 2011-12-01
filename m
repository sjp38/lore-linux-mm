Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A466F6B0093
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 12:00:04 -0500 (EST)
Received: by iapp10 with SMTP id p10so32731iap.14
        for <linux-mm@kvack.org>; Thu, 01 Dec 2011 09:00:02 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 1 Dec 2011 11:00:02 -0600
Message-ID: <CAB7xdin_4XJNCxb=e8_4w0ivwHscn12PcsFxSVV0dQ4nKk9uEw@mail.gmail.com>
Subject: add a vmalloc page into the LRU list
From: sheng qiu <herbert1984106@gmail.com>
Content-Type: multipart/alternative; boundary=90e6ba3fd25d881d4304b30ac874
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>

--90e6ba3fd25d881d4304b30ac874
Content-Type: text/plain; charset=ISO-8859-1

Hi all,

basically vmalloc pages cannot be swap out, so it's not in the LRU list. is
it possible to add a vmalloc page to the LRU list? so that kernel can stats
the usage on that page and swap out it if it's not frequently used?


Thanks,
Sheng

-- 
Sheng Qiu
Texas A & M University
Room 302 Wisenbaker
email: herbert1984106@gmail.com
College Station, TX 77843-3259

--90e6ba3fd25d881d4304b30ac874
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi all,<br><br>basically vmalloc pages cannot be swap out, so it&#39;s not =
in the LRU list. is it possible to add a vmalloc page to the LRU list? so t=
hat kernel can stats the usage on that page and swap out it if it&#39;s not=
 frequently used? <br>
<br><br>Thanks,<br>Sheng<br clear=3D"all"><br>-- <br>Sheng Qiu<br>Texas A &=
amp; M University<br>Room 302 Wisenbaker=A0 =A0 <br>email: <a href=3D"mailt=
o:herbert1984106@gmail.com">herbert1984106@gmail.com</a><br>College Station=
, TX 77843-3259<br>


--90e6ba3fd25d881d4304b30ac874--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
