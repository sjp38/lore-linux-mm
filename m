Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2EB6B0032
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 20:25:06 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so7729473pdj.22
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 17:25:06 -0700 (PDT)
References: <1379445730.79703.YahooMailNeo@web172205.mail.ir2.yahoo.com>
Message-ID: <1379550301.48901.YahooMailNeo@web172202.mail.ir2.yahoo.com>
Date: Thu, 19 Sep 2013 01:25:01 +0100 (BST)
From: Max B <txtmb@yahoo.fr>
Reply-To: Max B <txtmb@yahoo.fr>
Subject: shouldn't gcc use swap space as temp storage??
In-Reply-To: <1379445730.79703.YahooMailNeo@web172205.mail.ir2.yahoo.com>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="-1007433603-216861906-1379550301=:48901"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

---1007433603-216861906-1379550301=:48901
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

=0A=0A=0A=0A=0A=0AHi All,=0A=0ASee below for executable program.=0A=0A=0ASh=
ouldn't gcc use swap space as temp storage?=A0 Either my machine is set up =
improperly, or gcc does not (cannot?) access this capability.=0A=0A=0AIt se=
ems to me that programs should be able to access swap memory in these cases=
, but the behaviour has not been confirmed.=0A=0ACan someone please confirm=
 or correct me?=0A=0A=0AApologies if this is not the correct listserv for t=
he present discussion.=0A=0A=0AThanks for any/all help.=0A=0A=0ACheers,=0AM=
ax=0A=0A=0A/*=0A=A0* This program segfaults with the *bar array declaration=
.=0A=A0*=0A=A0* I wonder why it does not write the *foo array to swap space=
=0A=A0* then use the freed ram to allocate *bar.=0A=A0*=0A=A0* I have explo=
red the shell ulimit parameters to no avail.=0A=A0*=0A=A0* I have run this =
as root and in userland with the same outcome.=0A=A0*=0A=A0* It seems to be=
 a problem internal to gcc, but may also be a kernel issue.=0A=A0*=0A=A0*/=
=0A=0A#include <stdio.h>=0A#include <stdlib.h>=0A=0A#define NMAX 628757505=
=0A=0Aint main(int argc,char **argv) {=0A=A0 float *foo,*bar;=0A=0A=A0 foo=
=3Dcalloc(NMAX,sizeof(float));=0A=A0 fprintf(stderr,"%9.3f %9.3f\n",foo[0],=
foo[1]);=0A#if 1=0A=A0 bar=3Dcalloc(NMAX,sizeof(float));=0A=A0 fprintf(stde=
rr,"%9.3f %9.3f\n",bar[0],bar[1]);=0A#endif=0A=0A=A0 return=0A 0;=0A}
---1007433603-216861906-1379550301=:48901
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<html><body><div style=3D"color:#000; background-color:#fff; font-family:ti=
mes new roman, new york, times, serif;font-size:10pt"><br><div style=3D"fon=
t-family: times new roman, new york, times, serif; font-size: 10pt;"><div s=
tyle=3D"font-family: times new roman, new york, times, serif; font-size: 12=
pt;"><div class=3D"y_msg_container"><br><div id=3D"yiv4732563312"><div><div=
 style=3D"color:#000;background-color:#fff;font-family:times new roman, new=
 york, times, serif;font-size:10pt;"><div id=3D"yiv4732563312"><div><div st=
yle=3D"color:#000;background-color:#fff;font-family:times new roman, new yo=
rk, times, serif;font-size:10pt;"><div><br></div><div style=3D"color:rgb(0,=
 0, 0);font-size:13.3333px;font-family:times new roman, new york, times, se=
rif;background-color:transparent;font-style:normal;">Hi All,</div><div styl=
e=3D"color:rgb(0, 0, 0);font-size:13.3333px;font-family:times new roman, ne=
w york, times, serif;background-color:transparent;font-style:normal;"><br><=
/div><div
 style=3D"color:rgb(0, 0, 0);font-size:13.3333px;font-family:times new roma=
n, new york, times, serif;background-color:transparent;font-style:normal;">=
See below for executable program.<br></div><div style=3D"color:rgb(0, 0, 0)=
;font-size:13.3333px;font-family:times new roman, new york, times, serif;ba=
ckground-color:transparent;font-style:normal;"><br>Shouldn't gcc use swap s=
pace as temp storage?&nbsp; Either my machine is set up improperly, or gcc =
does not (cannot?) access this capability.<br><br></div><div style=3D"color=
:rgb(0, 0, 0);font-size:13.3333px;font-family:times new roman, new york, ti=
mes, serif;background-color:transparent;font-style:normal;">It seems to me =
that programs should be able to access swap memory in these cases, but the =
behaviour has not been confirmed.<br><br>Can someone please confirm or corr=
ect me?<br></div><div style=3D"color:rgb(0, 0, 0);font-size:13.3333px;font-=
family:times new roman, new york, times,
 serif;background-color:transparent;font-style:normal;"><br>Apologies if th=
is is not the correct listserv for the present discussion.<br><br></div><di=
v style=3D"color:rgb(0, 0,=0A 0);font-size:13.3333px;font-family:times new =
roman, new york, times, serif;background-color:transparent;font-style:norma=
l;">Thanks for any/all help.<br></div><div style=3D"color:rgb(0, 0, 0);font=
-size:13.3333px;font-family:times new roman, new york, times, serif;backgro=
und-color:transparent;font-style:normal;"><br></div><div style=3D"color:rgb=
(0, 0, 0);font-size:13.3333px;font-family:times new roman, new york, times,=
 serif;background-color:transparent;font-style:normal;">Cheers,</div><div s=
tyle=3D"color:rgb(0, 0, 0);font-size:13.3333px;font-family:times new roman,=
 new york, times, serif;background-color:transparent;font-style:normal;">Ma=
x</div><div style=3D"color:rgb(0, 0, 0);font-size:13.3333px;font-family:tim=
es new roman, new york, times, serif;background-color:transparent;font-styl=
e:normal;"><br></div><div style=3D"color:rgb(0, 0, 0);font-size:13.3333px;f=
ont-family:times new roman, new york, times,
 serif;background-color:transparent;font-style:normal;"><br></div><div styl=
e=3D"color:rgb(0, 0, 0);font-size:13.3333px;font-family:times new roman, ne=
w york, times, serif;background-color:transparent;font-style:normal;">/*<br=
>&nbsp;* This program segfaults with the *bar array declaration.<br>&nbsp;*=
<br>&nbsp;* I wonder why it does not write the *foo array to swap space<br>=
&nbsp;* then use the freed ram to allocate *bar.<br>&nbsp;*<br>&nbsp;* I ha=
ve explored the shell ulimit parameters to no avail.<br>&nbsp;*<br>&nbsp;* =
I have run this as root and in userland with the same outcome.<br>&nbsp;*<b=
r>&nbsp;* It seems to be a problem internal to gcc, but may also be a kerne=
l issue.<br>&nbsp;*<br>&nbsp;*/<br><br>#include &lt;stdio.h&gt;<br>#include=
 &lt;stdlib.h&gt;<br><br>#define NMAX 628757505<br><br>int main(int argc,ch=
ar **argv) {<br>&nbsp; float *foo,*bar;<br><br>&nbsp; foo=3Dcalloc(NMAX,siz=
eof(float));<br>&nbsp; fprintf(stderr,"%9.3f
 %9.3f\n",foo[0],foo[1]);<br>#if 1<br>&nbsp; bar=3Dcalloc(NMAX,sizeof(float=
));<br>&nbsp; fprintf(stderr,"%9.3f %9.3f\n",bar[0],bar[1]);<br>#endif<br><=
br>&nbsp; return=0A 0;<br>}</div><div style=3D"color:rgb(0, 0, 0);font-size=
:13.3333px;font-family:times new roman, new york, times, serif;background-c=
olor:transparent;font-style:normal;"><br></div></div></div></div></div></di=
v></div><br><br></div> </div> </div>  </div></body></html>
---1007433603-216861906-1379550301=:48901--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
