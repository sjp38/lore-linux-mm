Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 5B4266B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 15:22:13 -0400 (EDT)
References: 
Message-ID: <1379445730.79703.YahooMailNeo@web172205.mail.ir2.yahoo.com>
Date: Tue, 17 Sep 2013 20:22:10 +0100 (BST)
From: Max B <txtmb@yahoo.fr>
Reply-To: Max B <txtmb@yahoo.fr>
Subject: does gcc segfault when main memory is overfull?
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="-97308854-1164434340-1379445730=:79703"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

---97308854-1164434340-1379445730=:79703
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

=0A=0AHi All,=0A=0Adoes gcc segfault when main memory is overfull?=A0 See b=
elow for executable program.=0A=0A=0AIt seems to me that programs should be=
 able to access swap memory in these cases, but the behaviour has not been =
confirmed.=0A=0AIs this the correct listserv for the present discussion? Ap=
ologies if not.=0A=0AThanks for any/all help.=0A=0A=0ACheers,=0AMax=0A=0A=
=0A/*=0A=A0* This program segfaults with the *bar array declaration.=0A=A0*=
=0A=A0* I wonder why it does not write the *foo array to swap space=0A=A0* =
then use the freed ram to allocate *bar.=0A=A0*=0A=A0* I have explored the =
shell ulimit parameters to no avail.=0A=A0*=0A=A0* I have run this as root =
and in userland with the same outcome.=0A=A0*=0A=A0* It seems to be a probl=
em internal to gcc, but may also be a kernel issue.=0A=A0*=0A=A0*/=0A=0A#in=
clude <stdio.h>=0A#include <stdlib.h>=0A=0A#define NMAX 628757505=0A=0Aint =
main(int argc,char **argv) {=0A=A0 float *foo,*bar;=0A=0A=A0 foo=3Dcalloc(N=
MAX,sizeof(float));=0A=A0 fprintf(stderr,"%9.3f %9.3f\n",foo[0],foo[1]);=0A=
#if 1=0A=A0 bar=3Dcalloc(NMAX,sizeof(float));=0A=A0 fprintf(stderr,"%9.3f %=
9.3f\n",bar[0],bar[1]);=0A#endif=0A=0A=A0 return=0A 0;=0A}=0A
---97308854-1164434340-1379445730=:79703
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<html><body><div style=3D"color:#000; background-color:#fff; font-family:ti=
mes new roman, new york, times, serif;font-size:10pt"><div id=3D"yiv8758039=
615"><div><div style=3D"color:#000;background-color:#fff;font-family:times =
new roman, new york, times, serif;font-size:10pt;"><div><br></div><div styl=
e=3D"color:rgb(0, 0, 0);font-size:13.3333px;font-family:times new roman, ne=
w york, times, serif;background-color:transparent;font-style:normal;">Hi Al=
l,</div><div style=3D"color:rgb(0, 0, 0);font-size:13.3333px;font-family:ti=
mes new roman, new york, times, serif;background-color:transparent;font-sty=
le:normal;"><br></div><div style=3D"color:rgb(0, 0, 0);font-size:13.3333px;=
font-family:times new roman, new york, times, serif;background-color:transp=
arent;font-style:normal;">does gcc segfault when main memory is overfull?&n=
bsp; See below for executable program.<br></div><div style=3D"color:rgb(0, =
0, 0);font-size:13.3333px;font-family:times new roman, new york, times,
 serif;background-color:transparent;font-style:normal;"><br></div><div styl=
e=3D"color:rgb(0, 0, 0);font-size:13.3333px;font-family:times new roman, ne=
w york, times, serif;background-color:transparent;font-style:normal;">It se=
ems to me that programs should be able to access swap memory in these cases=
, but the behaviour has not been confirmed.</div><div style=3D"color:rgb(0,=
 0, 0);font-size:13.3333px;font-family:times new roman, new york, times, se=
rif;background-color:transparent;font-style:normal;"><br></div><div style=
=3D"color:rgb(0, 0, 0);font-size:13.3333px;font-family:times new roman, new=
 york, times, serif;background-color:transparent;font-style:normal;">Is thi=
s the correct listserv for the present discussion? Apologies if not.</div><=
div style=3D"color:rgb(0, 0, 0);font-size:13.3333px;font-family:times new r=
oman, new york, times, serif;background-color:transparent;font-style:normal=
;"><br></div><div style=3D"color:rgb(0, 0,
 0);font-size:13.3333px;font-family:times new roman, new york, times, serif=
;background-color:transparent;=0Afont-style:normal;">Thanks for any/all hel=
p.<br></div><div style=3D"color:rgb(0, 0, 0);font-size:13.3333px;font-famil=
y:times new roman, new york, times, serif;background-color:transparent;font=
-style:normal;"><br></div><div style=3D"color:rgb(0, 0, 0);font-size:13.333=
3px;font-family:times new roman, new york, times, serif;background-color:tr=
ansparent;font-style:normal;">Cheers,</div><div style=3D"color:rgb(0, 0, 0)=
;font-size:13.3333px;font-family:times new roman, new york, times, serif;ba=
ckground-color:transparent;font-style:normal;">Max</div><div style=3D"color=
:rgb(0, 0, 0);font-size:13.3333px;font-family:times new roman, new york, ti=
mes, serif;background-color:transparent;font-style:normal;"><br></div><div =
style=3D"color:rgb(0, 0, 0);font-size:13.3333px;font-family:times new roman=
, new york, times, serif;background-color:transparent;font-style:normal;"><=
br></div><div style=3D"color:rgb(0, 0, 0);font-size:13.3333px;font-family:t=
imes new roman, new york, times,
 serif;background-color:transparent;font-style:normal;">/*<br>&nbsp;* This =
program segfaults with the *bar array declaration.<br>&nbsp;*<br>&nbsp;* I =
wonder why it does not write the *foo array to swap space<br>&nbsp;* then u=
se the freed ram to allocate *bar.<br>&nbsp;*<br>&nbsp;* I have explored th=
e shell ulimit parameters to no avail.<br>&nbsp;*<br>&nbsp;* I have run thi=
s as root and in userland with the same outcome.<br>&nbsp;*<br>&nbsp;* It s=
eems to be a problem internal to gcc, but may also be a kernel issue.<br>&n=
bsp;*<br>&nbsp;*/<br><br>#include &lt;stdio.h&gt;<br>#include &lt;stdlib.h&=
gt;<br><br>#define NMAX 628757505<br><br>int main(int argc,char **argv) {<b=
r>&nbsp; float *foo,*bar;<br><br>&nbsp; foo=3Dcalloc(NMAX,sizeof(float));<b=
r>&nbsp; fprintf(stderr,"%9.3f %9.3f\n",foo[0],foo[1]);<br>#if 1<br>&nbsp; =
bar=3Dcalloc(NMAX,sizeof(float));<br>&nbsp; fprintf(stderr,"%9.3f %9.3f\n",=
bar[0],bar[1]);<br>#endif<br><br>&nbsp; return=0A 0;<br>}</div><div style=
=3D"color:rgb(0, 0, 0);font-size:13.3333px;font-family:times new roman, new=
 york, times, serif;background-color:transparent;font-style:normal;"><br></=
div></div></div></div></div></body></html>
---97308854-1164434340-1379445730=:79703--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
