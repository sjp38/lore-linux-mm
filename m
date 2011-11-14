Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7E0906B002D
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 01:02:10 -0500 (EST)
References: <1320766015.85140.YahooMailNeo@web162006.mail.bf1.yahoo.com>
Message-ID: <1321250527.64002.YahooMailNeo@web162003.mail.bf1.yahoo.com>
Date: Sun, 13 Nov 2011 22:02:07 -0800 (PST)
From: Pintu Agarwal <pintu_agarwal@yahoo.com>
Reply-To: Pintu Agarwal <pintu_agarwal@yahoo.com>
Subject: HELP needed :  Mali and UMP drivers : Rss and Pss pages always 0
In-Reply-To: <1320766015.85140.YahooMailNeo@web162006.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "pintu_agarwal@yahoo.com" <pintu_agarwal@yahoo.com>

Dear All,=0A=0AThis is regarding the Mali and UMP drivers for kernel 2.6.36=
.=0A=0AThe Rss and Pss pages for Mali and ump drivers are always zero.=0AWh=
en I do : =0A#cat /proc/1936/smaps | grep -A 11 /dev/ump=0A43698000-4381000=
0 rw-s 0000e000 00:11 6751=A0=A0=A0=A0=A0=A0 /dev/ump=0ASize:=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A01504 kB=0ARss:=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A00 kB=0APss:=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A00 kB=0AShared_Clean:=A0=
=A0=A0=A0=A0=A0=A0=A00 kB=0AShared_Dirty:=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=
=0APrivate_Clean:=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=0APrivate_Dirty:=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A00 kB=0AReferenced:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 0 kB=0ASwap:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=
=A0=A00 kB=0AKernelPageSize:=A0=A0=A0=A0=A0=A0=A04 kB=0AMMUPageSize:=A0=A0=
=A0=A0=A0=A0=A0=A0 4 kB=0A-------------------------------------------------=
---------------------=0AThe Rss and Pss pages are always 0KB.=0A=0AAny help=
 on this will be great.=0AAnyone who knows about Rss and Pss pages can prov=
ide some pointers to debug further.=0A=0A=0AThanks, Regards,=0APintu=0A=0A=
=0A=0A----- Original Message -----=0A> From: Pintu Agarwal <pintu_agarwal@y=
ahoo.com>=0A> To: "linux-mm@kvack.org" <linux-mm@kvack.org>; "linux-kernel@=
vger.kernel.org" <linux-kernel@vger.kernel.org>=0A> Cc: =0A> Sent: Tuesday,=
 8 November 2011 8:56 PM=0A> Subject: HELP : Rss and Pss pages are always 0=
 for some drivers. Why?=0A> =0A> Dear All,=0A> =A0=0A> I have a problem reg=
arding RSS and PSS pages always showing zero=A0for some PID.=0A> =A0=0A> We=
 are using customized kernel2.6.36 (arm with no swap).=0A> =A0=0A> We are h=
aving a menu-screen application (current PID 1939)=0A> =A0=0A> When I do ca=
t /proc/1939/smaps we are getting "Rss", "Pss" =0A> page as always zero for=
 some of the=A0modules=A0 /dev/ump and /dev/mali.=0A> The output is as foll=
ows:-=0A> cat /proc/1936/smaps | grep -A 11 /dev/ump=0A> 43698000-43810000 =
rw-s 0000e000 00:11 6751=A0=A0=A0=A0=A0=A0 /dev/ump=0A> Size:=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 1504 kB=0A> Rss:=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=0A> Pss:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 0 kB=0A> Shared_Clean:=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 k=
B=0A> Shared_Dirty:=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=0A> Private_Clean:=A0=
=A0=A0=A0=A0=A0=A0=A0 0 kB=0A> Private_Dirty:=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=
=0A> Referenced:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=0A> Swap:=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=0A> KernelPageSize:=A0=A0=
=A0=A0=A0=A0=A0 4 kB=0A> MMUPageSize:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 4 kB=0A=
> ----------------------------------------------------------------------=0A=
> =A0=0A> I wanted to understand why Rss and Pss pages information for only=
 /dev/ump =0A> (similarly for /dev/mali)=A0is not shown correctly by smaps.=
=0A> Where could be the problem and where I should debug?=0A> =A0=0A> Any i=
nformation on this will be a great help.=0A> =A0=0A> =A0=0A> =A0=0A> Thanks=
, Regards,=0A> Pintu Kumar=0A> =0A> --=0A> To unsubscribe, send a message w=
ith 'unsubscribe linux-mm' in=0A> the body to majordomo@kvack.org.=A0 For m=
ore info on Linux MM,=0A> see: http://www.linux-mm.org/ .=0A> Fight unfair =
telecom internet charges in Canada: sign http://stopthemeter.ca/=0A> Don't =
email: <a href=3Dmailto:"dont@kvack.org"> =0A> email@kvack.org </a>=0A>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
