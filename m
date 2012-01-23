Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id A96416B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 04:19:21 -0500 (EST)
Message-ID: <1327310360.96918.YahooMailNeo@web162003.mail.bf1.yahoo.com>
Date: Mon, 23 Jan 2012 01:19:20 -0800 (PST)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: [Help] : RSS/PSS showing 0 during smaps for Xorg
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="1705842018-575703137-1327310360=:96918"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

--1705842018-575703137-1327310360=:96918
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

Dear All,=0A=A0=0AI am facing one problem for one of my kernel module for o=
ur linux mobile with kernel2.6.36.=0A=A0=0AWhen I do cat /proc/<Xorg pid>/s=
maps | grep -A 11 /dev/ump , to track information for my=A0ump module,=0Awe=
 always get Rss/Pss as 0 kB as shown below:=0Acat /proc/1731/smaps | grep -=
A 11 /dev/ump=0A414db000-415ff000 rw-s 00015000 00:12 6803=A0=A0=A0=A0=A0=
=A0 /dev/ump=0ASize:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 1168 kB=0ARs=
s:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=0APss:=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB=0Atrack_rss_value =3D=
 0, iswalkcalled =3D 1, smap_pte_range_called =3D 1,=A0swap_pte =3D 0,=A0no=
t_pte_present =3D 0,=A0not_normal_page =3D 1=0Aisspecial =3D 0, not_special=
 =3D 1, isMixedMap =3D 0, pfnpages_null =3D 0, pfnoff_flag =3D 0, not_cow_m=
apping =3D 1,=A0normal_page_end =3D 0=0A=A0=0AAfter tracing down the proble=
m, I found out that during "show_smaps" in fs/proc/task_mmu.c and during ca=
ll to smaps_pte_range the vm_normal_page() is always returning NULL for our=
 /dev/ump driver.=0A(smaps_pte_range() is the place where Rss/Pss informati=
on is populated)=0AThus mss->resident (Rss value) is never getting incremen=
ted.=A0 =0A=A0=0ATo trace the problem I added few flags during show_smaps &=
 vm_normal_page() as shown above. The value of 1 indicates that the conditi=
on is executed.=0AThus "normal_page_end" indicates that the "vm_normal_page=
" has never ended successfully and always returns from =0A"!is_cow_mapping(=
)".=0A=A0=0ASo, I wanted to know the main cause for vm_normal_page() always=
 returning NULL page for our ump driver. =0AWhat is that I am missing in my=
 driver ?=0A=A0=0ACan anyone please let me know what could be the problem i=
n our driver.=0A=A0=0AThanks.=0A=A0=0AWith Regards,=0APintu
--1705842018-575703137-1327310360=:96918
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<html><body><div style=3D"color:#000; background-color:#fff; font-family:Co=
urier New, courier, monaco, monospace, sans-serif;font-size:12pt"><div styl=
e=3D"RIGHT: auto">Dear All,</div>
<div style=3D"RIGHT: auto">&nbsp;</div>
<div style=3D"RIGHT: auto">I am facing one problem for one of my kernel mod=
ule for our linux mobile with kernel2.6.36.</div>
<div style=3D"RIGHT: auto">&nbsp;</div>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">When I do cat /proc/=
&lt;Xorg pid&gt;/smaps | grep -A 11 /dev/ump , to track information for my&=
nbsp;ump module,</SPAN></DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">we always get Rss/Ps=
s as 0 kB as shown below:</SPAN></DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">cat /proc/1731/smaps=
 | grep -A 11 /dev/ump</SPAN></DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">414db000-415ff000 rw=
-s 00015000 00:12 6803&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /dev/ump<BR>Size=
:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp; 1168 kB<BR>Rss:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 kB</SPAN></DI=
V>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">Pss:&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp; 0 kB</SPAN></DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"><SPAN style=3D"RIGHT=
: auto">track_rss_value =3D 0, iswalkcalled =3D 1, smap_pte_range_called =
=3D 1,&nbsp;swap_pte =3D 0,&nbsp;not_pte_present =3D 0,&nbsp;not_normal_pag=
e =3D 1<BR>isspecial =3D 0, not_special =3D 1, isMixedMap =3D 0, pfnpages_n=
ull =3D 0, pfnoff_flag =3D 0, not_cow_mapping =3D 1,&nbsp;normal_page_end =
=3D 0</SPAN></SPAN></DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"><SPAN style=3D"RIGHT=
: auto"></SPAN></SPAN>&nbsp;</DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"><SPAN style=3D"RIGHT=
: auto">
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">After tracing down t=
he problem, I found out that during "show_smaps" in fs/proc/task_mmu.c and =
during call to smaps_pte_range the vm_normal_page() is always returning NUL=
L for our /dev/ump driver.</SPAN></DIV>
<DIV><SPAN>(smaps_pte_range() is the place where Rss/Pss information is pop=
ulated)</SPAN></DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">Thus mss-&gt;residen=
t (Rss value) is never getting incremented.&nbsp; </SPAN></DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"></SPAN>&nbsp;</DIV><=
/SPAN></SPAN></DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"><SPAN style=3D"RIGHT=
: auto">To trace the problem I added few flags during show_smaps &amp; vm_n=
ormal_page() as shown above. The value of 1 indicates that the condition is=
 executed.</SPAN></SPAN></DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"><SPAN style=3D"RIGHT=
: auto">Thus "normal_page_end" indicates that the "vm_normal_page" has neve=
r ended successfully and always returns from </SPAN></SPAN></DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"><SPAN style=3D"RIGHT=
: auto">"!is_cow_mapping()".</SPAN></SPAN></DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"><SPAN style=3D"RIGHT=
: auto"></SPAN></SPAN>&nbsp;</DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"><SPAN style=3D"RIGHT=
: auto">So, I wanted to know the main cause for vm_normal_page() always ret=
urning NULL page for our ump driver.
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">What is that I am mi=
ssing in my driver ?</SPAN></DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"></SPAN>&nbsp;</DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">Can anyone please le=
t me know what could be the problem in our driver.</SPAN></DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"></SPAN>&nbsp;</DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">Thanks.</SPAN></DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"></SPAN>&nbsp;</DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">With Regards,</SPAN>=
</DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto">Pintu</SPAN></DIV>
<DIV style=3D"RIGHT: auto"><SPAN style=3D"RIGHT: auto"><VAR id=3Dyui-ie-cur=
sor></VAR></SPAN>&nbsp;</DIV></SPAN></SPAN></DIV></div></body></html>
--1705842018-575703137-1327310360=:96918--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
