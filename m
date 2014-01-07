Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f54.google.com (mail-bk0-f54.google.com [209.85.214.54])
	by kanga.kvack.org (Postfix) with ESMTP id BFF556B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 05:32:49 -0500 (EST)
Received: by mail-bk0-f54.google.com with SMTP id v16so172325bkz.27
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 02:32:49 -0800 (PST)
Received: from mail-bk0-x229.google.com (mail-bk0-x229.google.com [2a00:1450:4008:c01::229])
        by mx.google.com with ESMTPS id o5si24026776bkr.320.2014.01.07.02.32.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 02:32:48 -0800 (PST)
Received: by mail-bk0-f41.google.com with SMTP id v15so172081bkz.0
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 02:32:48 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 7 Jan 2014 16:02:48 +0530
Message-ID: <CAK25hWMoAOXbeuJU73Mcd36KfW=Eam3dEHuyZhdndzEY6dev_g@mail.gmail.com>
Subject: [LSF/MM ATTEND] Stackable Union Filesystem Implementation
From: Saket Sinha <saket.sinha89@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b624eaad305e804ef5ee56c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

--047d7b624eaad305e804ef5ee56c
Content-Type: text/plain; charset=ISO-8859-1

I would like to attend LSF/MM summit. I will like to discuss approach to be
taken to finally bring up a Union Filesystem for Linux kernel.

My tryst with Union Filesystem began when I was involved developing a
filesystem as a part of  GSOC2013(Google Summer of Code) for CERN called
Hepunion Filesystem.

CERN needs a union filesystem for LHCb to provide fast diskless booting for
its nodes. For such an implementation, they need a file system with two
branches a Read-Write and a Read Only so they decided to write a completely
new union file system called Hepunion. The driver was  partially completed and
worked somewhat with some issues on 2.6.18. since they were using
SCL5(Scientific
Linux),

Now since LHCb is  moving to newer kernels, we ported it to newer
kernels but this is where the problem started. The design of our
filesystem was this that we used "path" to map the VFS and the lower
filesystems. With the addition of RCU-lookup in 2.6.35, a lot of
locking was added  in kernel functions like kern_path and made our
driver unstable beyond repair.

So now we are redesigning the entire thing from scratch.

We want to develop this Filesystem to finally have a stackable union
filesystem for the mainline Linux kernel . For such an effort,
collaborative development and community support is a must.


For the redesign, AFAIK
I can think of two ways to do it-

 1. VFS-based stacking solution- I would like to cite the work done by
Valerie Aurora was closest.

 2. Non-VFS-based stacking solution -  UnionFS, Aufs and the new Overlay FS

Patches for kernel exists for overlayfs & unionfs.
What is  communities view like which one would be good fit to go with?

The use case that I am looking from the stackable filesystem is  that of
"diskless node handling" (for CERN where it is required to provide a faster
diskless
booting to the Large Hadron Collider Beauty nodes).

 For this we need a
1. A global Read Only FIlesystem
2. A client-specific Read Write FIlesystem via NFS
3. A local Merged(of the above two) Read Write FIlesystem on ramdisk.

Thus to design such a fileystem I need community support and hence want to
attend LSF/MM summit.

  Regards,
  Saket Sinha

--047d7b624eaad305e804ef5ee56c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><br></div><span style=3D"font-family:arial,sans-serif=
;font-size:13px"><div>I would like=A0<span class=3D"" style=3D"background-c=
olor:rgb(255,255,204)">to</span>=A0<span class=3D"" style=3D"background-col=
or:rgb(255,255,204)">attend</span>=A0<span class=3D"" style=3D"background-c=
olor:rgb(255,255,204)">LSF</span>/<span class=3D"" style=3D"background-colo=
r:rgb(255,255,204)">MM</span>=A0summit. I will like to discuss approach to =
be taken to finally bring up a Union Filesystem for Linux kernel.</div>
<div><br></div><div>My tryst with Union Filesystem began when I was involve=
d developing a filesystem as a part of =A0GSOC2013(Google Summer of Code) f=
or CERN called Hepunion Filesystem.</div></span><div><br></div><span style=
=3D"font-family:arial,sans-serif;font-size:13px">CERN needs a union filesys=
tem for LHCb to provide fast diskless=A0</span><span style=3D"font-family:a=
rial,sans-serif;font-size:13px">booting for its nodes. For such an implemen=
tation, they need a file=A0</span><span style=3D"font-family:arial,sans-ser=
if;font-size:13px">system with two branches a Read-Write and a Read Only so=
 they decided=A0</span><span style=3D"font-family:arial,sans-serif;font-siz=
e:13px">to write a completely new union file system called Hepunion. The dr=
iver was=A0</span><span style=3D"font-family:arial,sans-serif;font-size:13p=
x">=A0partially completed</span><span style=3D"font-family:arial,sans-serif=
;font-size:13px">=A0and worked somewhat with some issues=A0on 2.6.18. </spa=
n><span style=3D"font-family:arial,sans-serif;font-size:13px">since they we=
re using=A0</span><span style=3D"font-family:arial,sans-serif;font-size:13p=
x">SCL5(Scientific Linux),=A0</span><br style=3D"font-family:arial,sans-ser=
if;font-size:13px">
<br style=3D"font-family:arial,sans-serif;font-size:13px"><span style=3D"fo=
nt-family:arial,sans-serif;font-size:13px">Now since LHCb is =A0moving to n=
ewer kernels, we ported it to newer</span><br style=3D"font-family:arial,sa=
ns-serif;font-size:13px">
<span style=3D"font-family:arial,sans-serif;font-size:13px">kernels but thi=
s is where the problem started. The design of our</span><br style=3D"font-f=
amily:arial,sans-serif;font-size:13px"><span style=3D"font-family:arial,san=
s-serif;font-size:13px">filesystem was this that we used &quot;path&quot; t=
o map the VFS and the lower</span><br style=3D"font-family:arial,sans-serif=
;font-size:13px">
<span style=3D"font-family:arial,sans-serif;font-size:13px">filesystems. Wi=
th the addition of RCU-lookup in 2.6.35, a lot of</span><br style=3D"font-f=
amily:arial,sans-serif;font-size:13px"><span style=3D"font-family:arial,san=
s-serif;font-size:13px">locking was added =A0in kernel functions like kern_=
path and made our</span><br style=3D"font-family:arial,sans-serif;font-size=
:13px">
<span style=3D"font-family:arial,sans-serif;font-size:13px">driver unstable=
 beyond repair.</span><br style=3D"font-family:arial,sans-serif;font-size:1=
3px"><br>So now we are redesigning the entire thing from scratch.=A0<div><b=
r>
<div>We want to develop this Filesystem to finally have a stackable union f=
ilesystem for the mainline Linux kernel . For such an effort, collaborative=
 development and community support is a must.</div><div><br></div><div>
<br><span style=3D"font-family:arial,sans-serif;font-size:13px">For the red=
esign, AFAIK</span><br style=3D"font-family:arial,sans-serif;font-size:13px=
"><span style=3D"font-family:arial,sans-serif;font-size:13px">I can think o=
f two ways to do it-</span><br style=3D"font-family:arial,sans-serif;font-s=
ize:13px">
<br style=3D"font-family:arial,sans-serif;font-size:13px"><span style=3D"fo=
nt-family:arial,sans-serif;font-size:13px">=A01. VFS-based stacking solutio=
n- I would like to cite the work done by</span><br style=3D"font-family:ari=
al,sans-serif;font-size:13px">
<span style=3D"font-family:arial,sans-serif;font-size:13px">Valerie Aurora =
was closest.</span><br style=3D"font-family:arial,sans-serif;font-size:13px=
"><br style=3D"font-family:arial,sans-serif;font-size:13px"><span style=3D"=
font-family:arial,sans-serif;font-size:13px">=A02. Non-VFS-based stacking s=
olution - =A0UnionFS, Aufs and the new Overlay FS</span><br style=3D"font-f=
amily:arial,sans-serif;font-size:13px">
<br style=3D"font-family:arial,sans-serif;font-size:13px"><span style=3D"fo=
nt-family:arial,sans-serif;font-size:13px">Patches for kernel exists for ov=
erlayfs &amp; unionfs.</span><br style=3D"font-family:arial,sans-serif;font=
-size:13px">
<span style=3D"font-family:arial,sans-serif;font-size:13px">What is =A0comm=
unities view like which one would be good fit to go with?</span><br style=
=3D"font-family:arial,sans-serif;font-size:13px"><br style=3D"font-family:a=
rial,sans-serif;font-size:13px">
<span style=3D"font-family:arial,sans-serif;font-size:13px">The use case th=
at I am looking from the stackable filesystem is =A0that of &quot;diskless =
node=A0</span><span style=3D"font-family:arial,sans-serif;font-size:13px">h=
andling&quot; (for CERN where it is required to provide a faster diskless</=
span><br style=3D"font-family:arial,sans-serif;font-size:13px">
<span style=3D"font-family:arial,sans-serif;font-size:13px">booting to the =
Large Hadron Collider Beauty nodes).</span><br style=3D"font-family:arial,s=
ans-serif;font-size:13px"><br style=3D"font-family:arial,sans-serif;font-si=
ze:13px">
<span style=3D"font-family:arial,sans-serif;font-size:13px">=A0For this we =
need a</span><br style=3D"font-family:arial,sans-serif;font-size:13px"><spa=
n style=3D"font-family:arial,sans-serif;font-size:13px">1. A global Read On=
ly FIlesystem</span><br style=3D"font-family:arial,sans-serif;font-size:13p=
x">
<span style=3D"font-family:arial,sans-serif;font-size:13px">2. A client-spe=
cific Read Write FIlesystem via NFS</span><br style=3D"font-family:arial,sa=
ns-serif;font-size:13px"><span style=3D"font-family:arial,sans-serif;font-s=
ize:13px">3. A local Merged(of the above two) Read Write FIlesystem on ramd=
isk.</span><br style=3D"font-family:arial,sans-serif;font-size:13px">
<br>Thus to design such a fileystem I need community support and hence want=
 to attend=A0<span class=3D"" style=3D"font-family:arial,sans-serif;font-si=
ze:13px;background-color:rgb(255,255,204)">LSF</span><span style=3D"font-fa=
mily:arial,sans-serif;font-size:13px">/</span><span class=3D"" style=3D"fon=
t-family:arial,sans-serif;font-size:13px;background-color:rgb(255,255,204)"=
>MM</span><span style=3D"font-family:arial,sans-serif;font-size:13px">=A0su=
mmit.</span><br style=3D"font-family:arial,sans-serif;font-size:13px">
<br style=3D"font-family:arial,sans-serif;font-size:13px"><span style=3D"fo=
nt-family:arial,sans-serif;font-size:13px">=A0 Regards,</span><br style=3D"=
font-family:arial,sans-serif;font-size:13px"><span style=3D"font-family:ari=
al,sans-serif;font-size:13px">=A0 Saket Sinha</span><br>
</div></div></div>

--047d7b624eaad305e804ef5ee56c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
