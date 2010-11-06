Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3D3586B00A6
	for <linux-mm@kvack.org>; Sat,  6 Nov 2010 12:23:52 -0400 (EDT)
Received: by wwj40 with SMTP id 40so4216464wwj.26
        for <linux-mm@kvack.org>; Sat, 06 Nov 2010 09:23:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87lj597hp9.fsf@gmail.com>
References: <87lj597hp9.fsf@gmail.com>
Date: Sat, 6 Nov 2010 09:23:49 -0700
Message-ID: <AANLkTi=mprHyKd=bvr=n9UaN_KVjd3acir1pigayqHKT@mail.gmail.com>
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
From: Wayne Davison <wayned@samba.org>
Content-Type: multipart/alternative; boundary=000e0cd72c00ed327f049464d02f
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--000e0cd72c00ed327f049464d02f
Content-Type: text/plain; charset=UTF-8

On Wed, Nov 3, 2010 at 10:58 PM, Ben Gamari <bgamari.foss@gmail.com> wrote:

> It looks like a few folks have discussed addressing the issue in the past,
> but nothing has happened as of 2.6.36.


Yeah, the linux code for this has long been buggy and near useless.  What is
really needed is a way for some file access to be marked as generating
low-priority cache data into the filesystem cache.  Such a flag should only
apply to newly cached data, so that copying a file that was cached by some
other program would not lower its cache priority (nor kick it out of the
cache).  If some other process comes along and reads from the low-priority
cache with a normal-priority read, it should get upgraded to normal
priority.  Something like that seems pretty simple and useful.

As for rsync, all current implementations of cache dropping are way too
klugey to go into rsync.  I'd personally suggest that someone create a
linux-specific pre-load library that overrides read() and write() calls and
use that when running rsync (or whatever else) to implement the extreme
weirdness that is currently needed for cache twiddling.

..wayne..

--000e0cd72c00ed327f049464d02f
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div class=3D"gmail_quote">On Wed, Nov 3, 2010 at 10:58 PM, Ben Gamari <spa=
n dir=3D"ltr">&lt;<a href=3D"mailto:bgamari.foss@gmail.com">bgamari.foss@gm=
ail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D=
"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
It looks like a few=C2=A0folks have discussed addressing the issue in the p=
ast, but nothing=C2=A0has happened as of 2.6.36.</blockquote><div><br></div=
><div>Yeah, the linux code for this has long been buggy and near useless. =
=C2=A0What is really needed is a way for some file access to be marked as g=
enerating low-priority cache data into the filesystem cache. =C2=A0Such a f=
lag should only apply to newly cached data, so that copying a file that was=
 cached by some other program would not lower its cache priority (nor kick =
it out of the cache). =C2=A0If some other process comes along and reads fro=
m the low-priority cache with a normal-priority read, it should get upgrade=
d to normal priority. =C2=A0Something like that seems pretty simple and use=
ful.</div>
<div><br></div><div>As for rsync, all current implementations of cache drop=
ping are way too klugey to go into rsync. =C2=A0I&#39;d personally suggest =
that someone create a linux-specific pre-load library that overrides read()=
 and write() calls and use that when running rsync (or whatever else) to im=
plement the extreme weirdness that is currently needed for cache twiddling.=
</div>
<div><br></div></div>..wayne..<br>

--000e0cd72c00ed327f049464d02f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
