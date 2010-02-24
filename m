Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AB6D36B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 06:36:32 -0500 (EST)
Received: by wyb42 with SMTP id 42so1008380wyb.14
        for <linux-mm@kvack.org>; Wed, 24 Feb 2010 03:36:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B849D4C.2090800@cn.fujitsu.com>
References: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name>
	 <690745ebd257c74a1c47d552fec7fbb0b5efb7d0.1266853233.git.kirill@shutemov.name>
	 <458c3169608cb333f390b2cb732565fec9fec67e.1266853234.git.kirill@shutemov.name>
	 <4B849D4C.2090800@cn.fujitsu.com>
Date: Wed, 24 Feb 2010 13:36:30 +0200
Message-ID: <cc557aab1002240336q2a8cab6evaae228a95ab9f672@mail.gmail.com>
Subject: Re: [PATCH v2 -mmotm 3/4] cgroups: Add simple listener of cgroup
	events to documentation
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 24, 2010 at 5:30 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>> + =C2=A0 =C2=A0 ret =3D dprintf(event_control, "%d %d %s", efd, cfd, arg=
v[2]);
>
> I found it won't return negative value for invalid input, though
> errno is set properly.

It looks like a glibc bug. I've file bug to glibc bugzilla:

http://sourceware.org/bugzilla/show_bug.cgi?id=3D11319

I'll fix cgroup_event_listener.c. Thanks!

> try:
> # ./cgroup_event_listner /cgroup/cgroup.procs abc
>
> while strace shows write() does return -1:
>
> # strace ./cgroup_event_listner /cgroup/cgroup.procs abc
> ...
> write(6, "7 5 abc"..., 7) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =3D -1 EINVAL (Invalid argument)
>
>> + =C2=A0 =C2=A0 if (ret =3D=3D -1) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 perror("Cannot write to cgro=
up.event_control");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
>> + =C2=A0 =C2=A0 }
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
