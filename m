Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3D5406B0032
	for <linux-mm@kvack.org>; Fri, 20 Sep 2013 23:14:01 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so150038pab.31
        for <linux-mm@kvack.org>; Fri, 20 Sep 2013 20:14:00 -0700 (PDT)
References: <1379445730.79703.YahooMailNeo@web172205.mail.ir2.yahoo.com> <1379550301.48901.YahooMailNeo@web172202.mail.ir2.yahoo.com> <20130919041451.GA2082@hp530>
Message-ID: <1379733236.53557.YahooMailNeo@web172201.mail.ir2.yahoo.com>
Date: Sat, 21 Sep 2013 04:13:56 +0100 (BST)
From: Max B <txtmb@yahoo.fr>
Reply-To: Max B <txtmb@yahoo.fr>
Subject: Re: shouldn't gcc use swap space as temp storage??
In-Reply-To: <20130919041451.GA2082@hp530>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="2036796846-1751807674-1379733236=:53557"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

--2036796846-1751807674-1379733236=:53557
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

=0A=0A=0AVladimir,=0A=0Amany thanks for pointing out that C99 is not my nat=
ive tongue.=0A=0AI plan to submit another segment of code -- this time in g=
uaranteed non-buggy gfortran -- which shows similar behaviour to the buggy =
gcc code.=A0 In fact the code was originally conceived and written in gfort=
ran, and I attempted (with evident failure as you so graciously point out) =
to translate it into gcc (seen below) for this linux-mm audience.=0A=0A=0AI=
 hope to gain productive feedback on the causes of the observed behaviour ,=
 and its solution, at this listserv because 1) the gfortran code is not bug=
gy and 2) I believe the linux-memory management listserv is the correct for=
um.=0A=0AI gather that many on this newsgroup may not have installed gfortr=
an by default, but quite possibly someone will be curious to see if s/he ca=
n replicate the observed behaviour, and either suggest a workaround or flag=
 it as a feature.=0A=0A=0ACheers,=0AMax=0A=0A=0A=0A=0A=0A=0A=0A=0A=0A______=
__________________________=0A De=A0: Vladimir Murzin <murzin.v@gmail.com>=
=0A=C0=A0: Max B <txtmb@yahoo.fr> =0ACc=A0: "linux-mm@kvack.org" <linux-mm@=
kvack.org> =0AEnvoy=E9 le : Jeudi 19 septembre 2013 6h14=0AObjet=A0: Re: sh=
ouldn't gcc use swap space as temp storage??=0A =0A=0AOn Thu, Sep 19, 2013 =
at 01:25:01AM +0100, Max B wrote:=0A> =0A> =0A> =0A> =0A> =0A> =0A> Hi All,=
=0A> =0A> See below for executable program.=0A> =0A> =0A> Shouldn't gcc use=
 swap space as temp storage?=A0 Either my machine is set up improperly, or =
gcc does not (cannot?) access this capability.=0A> =0A> =0A> It seems to me=
 that programs should be able to access swap memory in these cases, but the=
 behaviour has not been confirmed.=0A> =0A> Can someone please confirm or c=
orrect me?=0A> =0A=0AIt is not because your machine settings or gcc. Your c=
ode is buggy.=0A=0A> =0A> Apologies if this is not the correct listserv for=
 the present discussion.=0A> =0A=0AI think the proper list for C related qu=
estions is linux-c-programming or similar.=0A=0AVladimir=0A=0A> =0A> Thanks=
 for any/all help.=0A> =0A> =0A> Cheers,=0A> Max=0A> =0A> =0A> /*=0A> =A0* =
This program segfaults with the *bar array declaration.=0A> =A0*=0A> =A0* I=
 wonder why it does not write the *foo array to swap space=0A> =A0* then us=
e the freed ram to allocate *bar.=0A> =A0*=0A> =A0* I have explored the she=
ll ulimit parameters to no avail.=0A> =A0*=0A> =A0* I have run this as root=
 and in userland with the same outcome.=0A> =A0*=0A> =A0* It seems to be a =
problem internal to gcc, but may also be a kernel issue.=0A> =A0*=0A> =A0*/=
=0A> =0A> #include <stdio.h>=0A> #include <stdlib.h>=0A> =0A> #define NMAX =
628757505=0A> =0A> int main(int argc,char **argv) {=0A> =A0 float *foo,*bar=
;=0A> =0A> =A0 foo=3Dcalloc(NMAX,sizeof(float));=0A> =A0 fprintf(stderr,"%9=
.3f %9.3f\n",foo[0],foo[1]);=0A> #if 1=0A> =A0 bar=3Dcalloc(NMAX,sizeof(flo=
at));=0A> =A0 fprintf(stderr,"%9.3f %9.3f\n",bar[0],bar[1]);=0A> #endif=0A>=
 =0A> =A0 return=0A>=A0 0;=0A> }
--2036796846-1751807674-1379733236=:53557
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<html><body><div style=3D"color:#000; background-color:#fff; font-family:ti=
mes new roman, new york, times, serif;font-size:10pt"><div><span><br></span=
></div><div><br></div><div style=3D"color: rgb(0, 0, 0); font-size: 13.3333=
px; font-family: times new roman,new york,times,serif; background-color: tr=
ansparent; font-style: normal;">Vladimir,</div><div style=3D"color: rgb(0, =
0, 0); font-size: 13.3333px; font-family: times new roman,new york,times,se=
rif; background-color: transparent; font-style: normal;"><br></div><div sty=
le=3D"color: rgb(0, 0, 0); font-size: 13.3333px; font-family: times new rom=
an,new york,times,serif; background-color: transparent; font-style: normal;=
">many thanks for pointing out that C99 is not my native tongue.</div><div =
style=3D"color: rgb(0, 0, 0); font-size: 13.3333px; font-family: times new =
roman,new york,times,serif; background-color: transparent; font-style: norm=
al;"><br></div><div style=3D"color: rgb(0, 0, 0); font-size: 13.3333px;
 font-family: times new roman,new york,times,serif; background-color: trans=
parent; font-style: normal;">I plan to submit another segment of code -- th=
is time in guaranteed non-buggy gfortran -- which shows similar behaviour t=
o the buggy gcc code.&nbsp; In fact the code was originally conceived and w=
ritten in gfortran, and I attempted (with evident failure as you so graciou=
sly point out) to translate it into gcc (seen below) for this linux-mm audi=
ence.<br></div><div style=3D"color: rgb(0, 0, 0); font-size: 13.3333px; fon=
t-family: times new roman,new york,times,serif; background-color: transpare=
nt; font-style: normal;"><br></div><div style=3D"color: rgb(0, 0, 0); font-=
size: 13.3333px; font-family: times new roman,new york,times,serif; backgro=
und-color: transparent; font-style: normal;">I hope to gain productive feed=
back on the causes of the observed behaviour , and its solution, at this li=
stserv because 1) the gfortran code is not buggy and 2) I believe the
 linux-memory management listserv is the correct forum.</div><div style=3D"=
color: rgb(0, 0, 0); font-size: 13.3333px; font-family: times new roman,new=
 york,times,serif; background-color: transparent; font-style: normal;"><br>=
</div><div style=3D"color: rgb(0, 0, 0); font-size: 13.3333px; font-family:=
 times new roman,new york,times,serif; background-color: transparent; font-=
style: normal;">I gather that many on this newsgroup may not have installed=
 gfortran by default, but quite possibly someone will be curious to see if =
s/he can replicate the observed behaviour, and either suggest a workaround =
or flag it as a feature.<br></div><div style=3D"color: rgb(0, 0, 0); font-s=
ize: 13.3333px; font-family: times new roman,new york,times,serif; backgrou=
nd-color: transparent; font-style: normal;"><br></div><div style=3D"color: =
rgb(0, 0, 0); font-size: 13.3333px; font-family: times new roman,new york,t=
imes,serif; background-color: transparent; font-style:
 normal;">Cheers,</div><div style=3D"color: rgb(0, 0, 0); font-size: 13.333=
3px; font-family: times new roman,new york,times,serif; background-color: t=
ransparent; font-style: normal;">Max</div><div style=3D"color: rgb(0, 0, 0)=
; font-size: 13.3333px; font-family: times new roman,new york,times,serif; =
background-color: transparent; font-style: normal;"><br></div><div style=3D=
"color: rgb(0, 0, 0); font-size: 13.3333px; font-family: times new roman,ne=
w york,times,serif; background-color: transparent; font-style: normal;"><br=
></div><div style=3D"color: rgb(0, 0, 0); font-size: 13.3333px; font-family=
: times new roman,new york,times,serif; background-color: transparent; font=
-style: normal;"><br></div><div style=3D"color: rgb(0, 0, 0); font-size: 13=
.3333px; font-family: times new roman,new york,times,serif; background-colo=
r: transparent; font-style: normal;"><br></div><div style=3D"color: rgb(0, =
0, 0); font-size: 13.3333px; font-family: times new roman,new york,times,se=
rif;
 background-color: transparent; font-style: normal;"><br></div><div style=
=3D"color: rgb(0, 0, 0); font-size: 13.3333px; font-family: times new roman=
,new york,times,serif; background-color: transparent; font-style: normal;">=
<br></div><div style=3D"color: rgb(0, 0, 0); font-size: 13.3333px; font-fam=
ily: times new roman,new york,times,serif; background-color: transparent; f=
ont-style: normal;"><br></div><div style=3D"color: rgb(0, 0, 0); font-size:=
 13.3333px; font-family: times new roman,new york,times,serif; background-c=
olor: transparent; font-style: normal;"><br></div>  <div style=3D"font-fami=
ly: times new roman, new york, times, serif; font-size: 10pt;"> <div style=
=3D"font-family: times new roman, new york, times, serif; font-size: 12pt;"=
> <div dir=3D"ltr"> <hr size=3D"1">  <font face=3D"Arial" size=3D"2"> <b><s=
pan style=3D"font-weight:bold;">De&nbsp;:</span></b> Vladimir Murzin &lt;mu=
rzin.v@gmail.com&gt;<br> <b><span style=3D"font-weight: bold;">=C0&nbsp;:</=
span></b> Max B
 &lt;txtmb@yahoo.fr&gt; <br><b><span style=3D"font-weight: bold;">Cc&nbsp;:=
</span></b> "linux-mm@kvack.org" &lt;linux-mm@kvack.org&gt; <br> <b><span s=
tyle=3D"font-weight: bold;">Envoy=E9 le :</span></b> Jeudi 19 septembre 201=
3 6h14<br> <b><span style=3D"font-weight: bold;">Objet&nbsp;:</span></b> Re=
: shouldn't gcc use swap space as temp storage??<br> </font> </div> <div cl=
ass=3D"y_msg_container"><br>On Thu, Sep 19, 2013 at 01:25:01AM +0100, Max B=
 wrote:<br>&gt; <br>&gt; <br>&gt; <br>&gt; <br>&gt; <br>&gt; <br>&gt; Hi Al=
l,<br>&gt; <br>&gt; See below for executable program.<br>&gt; <br>&gt; <br>=
&gt; Shouldn't gcc use swap space as temp storage?&nbsp; Either my machine =
is set up improperly, or gcc does not (cannot?) access this capability.<br>=
&gt; <br>&gt; <br>&gt; It seems to me that programs should be able to acces=
s swap memory in these cases, but the behaviour has not been confirmed.<br>=
&gt; <br>&gt; Can someone please confirm or correct me?<br>&gt; <br><br>It =
is
 not because your machine settings or gcc. Your code is buggy.<br><br>&gt; =
<br>&gt; Apologies if this is not the correct listserv for the present disc=
ussion.<br>&gt; <br><br>I think the proper list for C related questions is =
linux-c-programming or similar.<br><br>Vladimir<br><br>&gt; <br>&gt; Thanks=
 for any/all help.<br>&gt; <br>&gt; <br>&gt; Cheers,<br>&gt; Max<br>&gt; <b=
r>&gt; <br>&gt; /*<br>&gt; &nbsp;* This program segfaults with the *bar arr=
ay declaration.<br>&gt; &nbsp;*<br>&gt; &nbsp;* I wonder why it does not wr=
ite the *foo array to swap space<br>&gt; &nbsp;* then use the freed ram to =
allocate *bar.<br>&gt; &nbsp;*<br>&gt; &nbsp;* I have explored the shell ul=
imit parameters to no avail.<br>&gt; &nbsp;*<br>&gt; &nbsp;* I have run thi=
s as root and in userland with the same outcome.<br>&gt; &nbsp;*<br>&gt; &n=
bsp;* It seems to be a problem internal to gcc, but may also be a kernel is=
sue.<br>&gt; &nbsp;*<br>&gt; &nbsp;*/<br>&gt; <br>&gt; #include
 &lt;stdio.h&gt;<br>&gt; #include &lt;stdlib.h&gt;<br>&gt; <br>&gt; #define=
 NMAX 628757505<br>&gt; <br>&gt; int main(int argc,char **argv) {<br>&gt; &=
nbsp; float *foo,*bar;<br>&gt; <br>&gt; &nbsp; foo=3Dcalloc(NMAX,sizeof(flo=
at));<br>&gt; &nbsp; fprintf(stderr,"%9.3f %9.3f\n",foo[0],foo[1]);<br>&gt;=
 #if 1<br>&gt; &nbsp; bar=3Dcalloc(NMAX,sizeof(float));<br>&gt; &nbsp; fpri=
ntf(stderr,"%9.3f %9.3f\n",bar[0],bar[1]);<br>&gt; #endif<br>&gt; <br>&gt; =
&nbsp; return<br>&gt;&nbsp; 0;<br>&gt; }<br><br><br></div> </div> </div>  <=
/div></body></html>
--2036796846-1751807674-1379733236=:53557--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
