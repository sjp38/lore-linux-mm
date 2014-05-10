Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 28F226B0038
	for <linux-mm@kvack.org>; Fri,  9 May 2014 23:01:58 -0400 (EDT)
Received: by mail-ig0-f172.google.com with SMTP id uy17so1901314igb.17
        for <linux-mm@kvack.org>; Fri, 09 May 2014 20:01:58 -0700 (PDT)
Received: from nm45.bullet.mail.ne1.yahoo.com (nm45.bullet.mail.ne1.yahoo.com. [98.138.120.52])
        by mx.google.com with SMTP id k4si1723554igx.11.2014.05.09.20.01.57
        for <linux-mm@kvack.org>;
        Fri, 09 May 2014 20:01:57 -0700 (PDT)
Message-ID: <1399690747.69805.YahooMailNeo@web160104.mail.bf1.yahoo.com>
Date: Fri, 9 May 2014 19:59:07 -0700 (PDT)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: [MM]: IOMMU and CMA buffer sharing
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="-1615118150-2088370353-1399690747=:69805"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>

---1615118150-2088370353-1399690747=:69805
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi,=0A=0AI have some queries regarding IOMMU and CMA buffer sharing.=0A=0AW=
e have an embedded linux device (kernel 3.10, RAM: 256Mb) in which camera a=
nd codec supports IOMMU but the display does not support IOMMU.=0AThus for =
camera capture we are using iommu buffers using ION/DMABUF. But for all dis=
play rendering we are using CMA buffers.=0ASo, the question is how to achie=
ve buffer sharing (zero-copy) between Camera and Display using only IOMMU?=
=0A=0ACurrently we are achieving zero-copy using CMA. And we are exploring =
options to use IOMMU.=0ANow we wanted to know which option is better? To us=
e IOMMU or CMA?=0A=0AIf anybody have come across these design please share =
your thoughts and results.=0A=0A=0AThank You!=0ARegards,=0APintu=0A
---1615118150-2088370353-1399690747=:69805
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: quoted-printable

<html><body><div style=3D"color:#000; background-color:#fff; font-family:Co=
urier New, courier, monaco, monospace, sans-serif;font-size:12pt"><div>Hi,<=
/div><div><br></div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; fon=
t-family: 'Courier New', courier, monaco, monospace, sans-serif; background=
-color: transparent; font-style: normal;">I have some queries regarding IOM=
MU and CMA buffer sharing.</div><div style=3D"color: rgb(0, 0, 0); font-siz=
e: 16px; font-family: 'Courier New', courier, monaco, monospace, sans-serif=
; background-color: transparent; font-style: normal;"><br></div><div style=
=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: 'Courier New', couri=
er, monaco, monospace, sans-serif; background-color: transparent; font-styl=
e: normal;">We have an embedded linux device (kernel 3.10, RAM: 256Mb) in w=
hich camera and codec supports IOMMU but the display does not support IOMMU=
.</div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-family:
 'Courier New', courier, monaco, monospace, sans-serif; background-color: t=
ransparent; font-style: normal;">Thus for camera capture we are using iommu=
 buffers using ION/DMABUF. But for all display rendering we are using CMA b=
uffers.</div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-famil=
y: 'Courier New', courier, monaco, monospace, sans-serif; background-color:=
 transparent; font-style: normal;">So, the question is how to achieve buffe=
r sharing (zero-copy) between Camera and Display using only IOMMU?</div><di=
v style=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: 'Courier New'=
, courier, monaco, monospace, sans-serif; background-color: transparent; fo=
nt-style: normal;"><br></div><div style=3D"color: rgb(0, 0, 0); font-size: =
16px; font-family: 'Courier New', courier, monaco, monospace, sans-serif; b=
ackground-color: transparent; font-style: normal;">Currently we are achievi=
ng zero-copy using CMA. And we are exploring options to use
 IOMMU.</div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-famil=
y: 'Courier New', courier, monaco, monospace, sans-serif; background-color:=
 transparent; font-style: normal;">Now we wanted to know which option is be=
tter? To use IOMMU or CMA?</div><div style=3D"color: rgb(0, 0, 0); font-siz=
e: 16px; font-family: 'Courier New', courier, monaco, monospace, sans-serif=
; background-color: transparent; font-style: normal;"><br></div><div style=
=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: 'Courier New', couri=
er, monaco, monospace, sans-serif; background-color: transparent; font-styl=
e: normal;">If anybody have come across these design please share your thou=
ghts and results.</div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; =
font-family: 'Courier New', courier, monaco, monospace, sans-serif; backgro=
und-color: transparent; font-style: normal;"><br></div><div style=3D"color:=
 rgb(0, 0, 0); font-size: 16px; font-family: 'Courier New', courier, monaco=
,
 monospace, sans-serif; background-color: transparent; font-style: normal;"=
><br></div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-family:=
 'Courier New', courier, monaco, monospace, sans-serif; background-color: t=
ransparent; font-style: normal;">Thank You!</div><div style=3D"color: rgb(0=
, 0, 0); font-size: 16px; font-family: 'Courier New', courier, monaco, mono=
space, sans-serif; background-color: transparent; font-style: normal;">Rega=
rds,</div><div style=3D"color: rgb(0, 0, 0); font-size: 16px; font-family: =
'Courier New', courier, monaco, monospace, sans-serif; background-color: tr=
ansparent; font-style: normal;">Pintu</div><div style=3D"color: rgb(0, 0, 0=
); font-size: 16px; font-family: 'Courier New', courier, monaco, monospace,=
 sans-serif; background-color: transparent; font-style: normal;"><br></div>=
</div></body></html>
---1615118150-2088370353-1399690747=:69805--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
