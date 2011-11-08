Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 738956B002D
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 10:26:57 -0500 (EST)
Message-ID: <1320766015.85140.YahooMailNeo@web162006.mail.bf1.yahoo.com>
Date: Tue, 8 Nov 2011 07:26:55 -0800 (PST)
From: Pintu Agarwal <pintu_agarwal@yahoo.com>
Reply-To: Pintu Agarwal <pintu_agarwal@yahoo.com>
Subject: HELP :  Rss and Pss pages are always 0 for some drivers. Why?
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Dear All,=0A=A0=0AI have a problem regarding RSS and PSS pages always showi=
ng zero=A0for some PID.=0A=A0=0AWe are using customized kernel2.6.36 (arm w=
ith no swap).=0A=A0=0AWe are having a menu-screen application (current PID =
1939)=0A=A0=0AWhen I do cat /proc/1939/smaps we are getting "Rss", "Pss" pa=
ge as always zero for some of the=A0modules=A0 /dev/ump and /dev/mali.=0ATh=
e output is as follows:-=0Acat /proc/1936/smaps | grep -A 11 /dev/ump=0A436=
98000-43810000 rw-s 0000e000 00:11 6751=A0=A0=A0=A0=A0=A0 /dev/ump=0ASize:=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 1504 kB=0ARss:=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=0APss:=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=0AShared_Clean:=A0=A0=A0=A0=A0=A0=A0=A0=A0=
 0 kB=0AShared_Dirty:=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=0APrivate_Clean:=A0=
=A0=A0=A0=A0=A0=A0=A0 0 kB=0APrivate_Dirty:=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=0A=
Referenced:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=0ASwap:=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=0AKernelPageSize:=A0=A0=A0=A0=A0=A0=
=A0 4 kB=0AMMUPageSize:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 4 kB=0A--------------=
--------------------------------------------------------=0A=A0=0AI wanted t=
o understand why Rss and Pss pages information for only /dev/ump (similarly=
 for /dev/mali)=A0is not shown correctly by smaps.=0AWhere could be the pro=
blem and where I should debug?=0A=A0=0AAny information on this will be a gr=
eat help.=0A=A0=0A=A0=0A=A0=0AThanks, Regards,=0APintu Kumar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
