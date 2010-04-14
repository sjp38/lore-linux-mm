Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3E624600374
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 03:19:05 -0400 (EDT)
Received: by gyg4 with SMTP id 4so3967614gyg.14
        for <linux-mm@kvack.org>; Wed, 14 Apr 2010 00:19:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <y2x28c262361004132313r1e2ca71frd042d5460d897730@mail.gmail.com>
References: <20100414135945.2b0a1e0d.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100414054144.GH2493@dastard>
	 <20100414145056.D147.A69D9226@jp.fujitsu.com>
	 <y2x28c262361004132313r1e2ca71frd042d5460d897730@mail.gmail.com>
Date: Wed, 14 Apr 2010 16:19:02 +0900
Message-ID: <w2u28c262361004140019pd8fe696ez609ece4a35527658@mail.gmail.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Chinner <david@fromorbit.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 3:13 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Wed, Apr 14, 2010 at 2:54 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
>>> On Wed, Apr 14, 2010 at 01:59:45PM +0900, KAMEZAWA Hiroyuki wrote:
>>> > On Wed, 14 Apr 2010 11:40:41 +1000
>>> > Dave Chinner <david@fromorbit.com> wrote:
>>> >
>>> > > =C2=A050) =C2=A0 =C2=A0 3168 =C2=A0 =C2=A0 =C2=A064 =C2=A0 xfs_vm_w=
ritepage+0xab/0x160 [xfs]
>>> > > =C2=A051) =C2=A0 =C2=A0 3104 =C2=A0 =C2=A0 384 =C2=A0 shrink_page_l=
ist+0x65e/0x840
>>> > > =C2=A052) =C2=A0 =C2=A0 2720 =C2=A0 =C2=A0 528 =C2=A0 shrink_zone+0=
x63f/0xe10
>>> >
>>> > A bit OFF TOPIC.
>>> >
>>> > Could you share disassemble of shrink_zone() ?
>>> >
>>> > In my environ.
>>> > 00000000000115a0 <shrink_zone>:
>>> > =C2=A0 =C2=A0115a0: =C2=A0 =C2=A0 =C2=A0 55 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0push =C2=A0 %rbp
>>> > =C2=A0 =C2=A0115a1: =C2=A0 =C2=A0 =C2=A0 48 89 e5 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mov =C2=A0 =C2=A0%rsp,%rbp
>>> > =C2=A0 =C2=A0115a4: =C2=A0 =C2=A0 =C2=A0 41 57 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 push =C2=A0 %r15
>>> > =C2=A0 =C2=A0115a6: =C2=A0 =C2=A0 =C2=A0 41 56 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 push =C2=A0 %r14
>>> > =C2=A0 =C2=A0115a8: =C2=A0 =C2=A0 =C2=A0 41 55 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 push =C2=A0 %r13
>>> > =C2=A0 =C2=A0115aa: =C2=A0 =C2=A0 =C2=A0 41 54 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 push =C2=A0 %r12
>>> > =C2=A0 =C2=A0115ac: =C2=A0 =C2=A0 =C2=A0 53 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0push =C2=A0 %rbx
>>> > =C2=A0 =C2=A0115ad: =C2=A0 =C2=A0 =C2=A0 48 83 ec 78 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 sub =C2=A0 =C2=A0$0x78,%rsp
>>> > =C2=A0 =C2=A0115b1: =C2=A0 =C2=A0 =C2=A0 e8 00 00 00 00 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0callq =C2=A0115b6 <shrink_zone+0x16>
>>> > =C2=A0 =C2=A0115b6: =C2=A0 =C2=A0 =C2=A0 48 89 75 80 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 mov =C2=A0 =C2=A0%rsi,-0x80(%rbp)
>>> >
>>> > disassemble seems to show 0x78 bytes for stack. And no changes to %rs=
p
>>> > until retrun.
>>>
>>> I see the same. I didn't compile those kernels, though. IIUC,
>>> they were built through the Ubuntu build infrastructure, so there is
>>> something different in terms of compiler, compiler options or config
>>> to what we are both using. Most likely it is the compiler inlining,
>>> though Chris's patches to prevent that didn't seem to change the
>>> stack usage.
>>>
>>> I'm trying to get a stack trace from the kernel that has shrink_zone
>>> in it, but I haven't succeeded yet....
>>
>> I also got 0x78 byte stack usage. Umm.. Do we discussed real issue now?
>>
>
> In my case, 0x110 byte in 32 bit machine.
> I think it's possible in 64 bit machine.
>
> 00001830 <shrink_zone>:
> =C2=A0 =C2=A01830: =C2=A0 =C2=A0 =C2=A0 55 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0push =C2=A0 %ebp
> =C2=A0 =C2=A01831: =C2=A0 =C2=A0 =C2=A0 89 e5 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mov =C2=A0 =C2=A0%esp,%ebp
> =C2=A0 =C2=A01833: =C2=A0 =C2=A0 =C2=A0 57 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0push =C2=A0 %edi
> =C2=A0 =C2=A01834: =C2=A0 =C2=A0 =C2=A0 56 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0push =C2=A0 %esi
> =C2=A0 =C2=A01835: =C2=A0 =C2=A0 =C2=A0 53 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0push =C2=A0 %ebx
> =C2=A0 =C2=A01836: =C2=A0 =C2=A0 =C2=A0 81 ec 10 01 00 00 =C2=A0 =C2=A0 =
=C2=A0 sub =C2=A0 =C2=A0$0x110,%esp
> =C2=A0 =C2=A0183c: =C2=A0 =C2=A0 =C2=A0 89 85 24 ff ff ff =C2=A0 =C2=A0 =
=C2=A0 mov =C2=A0 =C2=A0%eax,-0xdc(%ebp)
> =C2=A0 =C2=A01842: =C2=A0 =C2=A0 =C2=A0 89 95 20 ff ff ff =C2=A0 =C2=A0 =
=C2=A0 mov =C2=A0 =C2=A0%edx,-0xe0(%ebp)
> =C2=A0 =C2=A01848: =C2=A0 =C2=A0 =C2=A0 89 8d 1c ff ff ff =C2=A0 =C2=A0 =
=C2=A0 mov =C2=A0 =C2=A0%ecx,-0xe4(%ebp)
> =C2=A0 =C2=A0184e: =C2=A0 =C2=A0 =C2=A0 8b 41 04 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mov =C2=A0 =C2=A00x4(%ecx)
>
> my gcc is following as.
>
> barrios@barriostarget:~/mmotm$ gcc -v
> Using built-in specs.
> Target: i486-linux-gnu
> Configured with: ../src/configure -v --with-pkgversion=3D'Ubuntu
> 4.3.3-5ubuntu4'
> --with-bugurl=3Dfile:///usr/share/doc/gcc-4.3/README.Bugs
> --enable-languages=3Dc,c++,fortran,objc,obj-c++ --prefix=3D/usr
> --enable-shared --with-system-zlib --libexecdir=3D/usr/lib
> --without-included-gettext --enable-threads=3Dposix --enable-nls
> --with-gxx-include-dir=3D/usr/include/c++/4.3 --program-suffix=3D-4.3
> --enable-clocale=3Dgnu --enable-libstdcxx-debug --enable-objc-gc
> --enable-mpfr --enable-targets=3Dall --with-tune=3Dgeneric
> --enable-checking=3Drelease --build=3Di486-linux-gnu --host=3Di486-linux-=
gnu
> --target=3Di486-linux-gnu
> Thread model: posix
> gcc version 4.3.3 (Ubuntu 4.3.3-5ubuntu4)
>
>
> Is it depends on config?
> I attach my config.

I changed shrink list by noinline_for_stack.
The result is following as.


00001fe0 <shrink_zone>:
    1fe0:       55                      push   %ebp
    1fe1:       89 e5                   mov    %esp,%ebp
    1fe3:       57                      push   %edi
    1fe4:       56                      push   %esi
    1fe5:       53                      push   %ebx
    1fe6:       83 ec 4c                sub    $0x4c,%esp
    1fe9:       89 45 c0                mov    %eax,-0x40(%ebp)
    1fec:       89 55 bc                mov    %edx,-0x44(%ebp)
    1fef:       89 4d b8                mov    %ecx,-0x48(%ebp)

0x110 -> 0x4c.

Should we have to add noinline_for_stack for shrink_list?


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
