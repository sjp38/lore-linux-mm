Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A7A5F6B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 06:01:49 -0400 (EDT)
Received: by ywh26 with SMTP id 26so2890350ywh.12
        for <linux-mm@kvack.org>; Wed, 14 Apr 2010 03:01:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100414184213.f6bf11a7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100414135945.2b0a1e0d.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100414054144.GH2493@dastard>
	 <20100414145056.D147.A69D9226@jp.fujitsu.com>
	 <y2x28c262361004132313r1e2ca71frd042d5460d897730@mail.gmail.com>
	 <w2u28c262361004140019pd8fe696ez609ece4a35527658@mail.gmail.com>
	 <20100414184213.f6bf11a7.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 14 Apr 2010 19:01:47 +0900
Message-ID: <q2m28c262361004140301jba94a025nda755c1df2e04155@mail.gmail.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 6:42 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 14 Apr 2010 16:19:02 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Wed, Apr 14, 2010 at 3:13 PM, Minchan Kim <minchan.kim@gmail.com> wro=
te:
>> > On Wed, Apr 14, 2010 at 2:54 PM, KOSAKI Motohiro
>> > <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >>> On Wed, Apr 14, 2010 at 01:59:45PM +0900, KAMEZAWA Hiroyuki wrote:
>> >>> > On Wed, 14 Apr 2010 11:40:41 +1000
>> >>> > Dave Chinner <david@fromorbit.com> wrote:
>> >>> >
>> >>> > > =C2=A050) =C2=A0 =C2=A0 3168 =C2=A0 =C2=A0 =C2=A064 =C2=A0 xfs_v=
m_writepage+0xab/0x160 [xfs]
>> >>> > > =C2=A051) =C2=A0 =C2=A0 3104 =C2=A0 =C2=A0 384 =C2=A0 shrink_pag=
e_list+0x65e/0x840
>> >>> > > =C2=A052) =C2=A0 =C2=A0 2720 =C2=A0 =C2=A0 528 =C2=A0 shrink_zon=
e+0x63f/0xe10
>> >>> >
>> >>> > A bit OFF TOPIC.
>> >>> >
>> >>> > Could you share disassemble of shrink_zone() ?
>> >>> >
>> >>> > In my environ.
>> >>> > 00000000000115a0 <shrink_zone>:
>> >>> > =C2=A0 =C2=A0115a0: =C2=A0 =C2=A0 =C2=A0 55 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0push =C2=A0 %rbp
>> >>> > =C2=A0 =C2=A0115a1: =C2=A0 =C2=A0 =C2=A0 48 89 e5 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mov =C2=A0 =C2=A0%rsp,%rbp
>> >>> > =C2=A0 =C2=A0115a4: =C2=A0 =C2=A0 =C2=A0 41 57 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 push =C2=A0 %r15
>> >>> > =C2=A0 =C2=A0115a6: =C2=A0 =C2=A0 =C2=A0 41 56 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 push =C2=A0 %r14
>> >>> > =C2=A0 =C2=A0115a8: =C2=A0 =C2=A0 =C2=A0 41 55 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 push =C2=A0 %r13
>> >>> > =C2=A0 =C2=A0115aa: =C2=A0 =C2=A0 =C2=A0 41 54 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 push =C2=A0 %r12
>> >>> > =C2=A0 =C2=A0115ac: =C2=A0 =C2=A0 =C2=A0 53 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0push =C2=A0 %rbx
>> >>> > =C2=A0 =C2=A0115ad: =C2=A0 =C2=A0 =C2=A0 48 83 ec 78 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sub =C2=A0 =C2=A0$0x78,%rsp
>> >>> > =C2=A0 =C2=A0115b1: =C2=A0 =C2=A0 =C2=A0 e8 00 00 00 00 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0callq =C2=A0115b6 <shrink_zone+0x16>
>> >>> > =C2=A0 =C2=A0115b6: =C2=A0 =C2=A0 =C2=A0 48 89 75 80 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mov =C2=A0 =C2=A0%rsi,-0x80(%rbp)
>> >>> >
>> >>> > disassemble seems to show 0x78 bytes for stack. And no changes to =
%rsp
>> >>> > until retrun.
>> >>>
>> >>> I see the same. I didn't compile those kernels, though. IIUC,
>> >>> they were built through the Ubuntu build infrastructure, so there is
>> >>> something different in terms of compiler, compiler options or config
>> >>> to what we are both using. Most likely it is the compiler inlining,
>> >>> though Chris's patches to prevent that didn't seem to change the
>> >>> stack usage.
>> >>>
>> >>> I'm trying to get a stack trace from the kernel that has shrink_zone
>> >>> in it, but I haven't succeeded yet....
>> >>
>> >> I also got 0x78 byte stack usage. Umm.. Do we discussed real issue no=
w?
>> >>
>> >
>> > In my case, 0x110 byte in 32 bit machine.
>> > I think it's possible in 64 bit machine.
>> >
>> > 00001830 <shrink_zone>:
>> > =C2=A0 =C2=A01830: =C2=A0 =C2=A0 =C2=A0 55 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0push =C2=A0 %ebp
>> > =C2=A0 =C2=A01831: =C2=A0 =C2=A0 =C2=A0 89 e5 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mov =C2=A0 =C2=A0%esp,%ebp
>> > =C2=A0 =C2=A01833: =C2=A0 =C2=A0 =C2=A0 57 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0push =C2=A0 %edi
>> > =C2=A0 =C2=A01834: =C2=A0 =C2=A0 =C2=A0 56 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0push =C2=A0 %esi
>> > =C2=A0 =C2=A01835: =C2=A0 =C2=A0 =C2=A0 53 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0push =C2=A0 %ebx
>> > =C2=A0 =C2=A01836: =C2=A0 =C2=A0 =C2=A0 81 ec 10 01 00 00 =C2=A0 =C2=
=A0 =C2=A0 sub =C2=A0 =C2=A0$0x110,%esp
>> > =C2=A0 =C2=A0183c: =C2=A0 =C2=A0 =C2=A0 89 85 24 ff ff ff =C2=A0 =C2=
=A0 =C2=A0 mov =C2=A0 =C2=A0%eax,-0xdc(%ebp)
>> > =C2=A0 =C2=A01842: =C2=A0 =C2=A0 =C2=A0 89 95 20 ff ff ff =C2=A0 =C2=
=A0 =C2=A0 mov =C2=A0 =C2=A0%edx,-0xe0(%ebp)
>> > =C2=A0 =C2=A01848: =C2=A0 =C2=A0 =C2=A0 89 8d 1c ff ff ff =C2=A0 =C2=
=A0 =C2=A0 mov =C2=A0 =C2=A0%ecx,-0xe4(%ebp)
>> > =C2=A0 =C2=A0184e: =C2=A0 =C2=A0 =C2=A0 8b 41 04 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mov =C2=A0 =C2=A00x4(%ecx)
>> >
>> > my gcc is following as.
>> >
>> > barrios@barriostarget:~/mmotm$ gcc -v
>> > Using built-in specs.
>> > Target: i486-linux-gnu
>> > Configured with: ../src/configure -v --with-pkgversion=3D'Ubuntu
>> > 4.3.3-5ubuntu4'
>> > --with-bugurl=3Dfile:///usr/share/doc/gcc-4.3/README.Bugs
>> > --enable-languages=3Dc,c++,fortran,objc,obj-c++ --prefix=3D/usr
>> > --enable-shared --with-system-zlib --libexecdir=3D/usr/lib
>> > --without-included-gettext --enable-threads=3Dposix --enable-nls
>> > --with-gxx-include-dir=3D/usr/include/c++/4.3 --program-suffix=3D-4.3
>> > --enable-clocale=3Dgnu --enable-libstdcxx-debug --enable-objc-gc
>> > --enable-mpfr --enable-targets=3Dall --with-tune=3Dgeneric
>> > --enable-checking=3Drelease --build=3Di486-linux-gnu --host=3Di486-lin=
ux-gnu
>> > --target=3Di486-linux-gnu
>> > Thread model: posix
>> > gcc version 4.3.3 (Ubuntu 4.3.3-5ubuntu4)
>> >
>> >
>> > Is it depends on config?
>> > I attach my config.
>>
>> I changed shrink list by noinline_for_stack.
>> The result is following as.
>>
>>
>> 00001fe0 <shrink_zone>:
>> =C2=A0 =C2=A0 1fe0: =C2=A0 =C2=A0 =C2=A0 55 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0push =C2=A0 %ebp
>> =C2=A0 =C2=A0 1fe1: =C2=A0 =C2=A0 =C2=A0 89 e5 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mov =C2=A0 =C2=A0%esp,%ebp
>> =C2=A0 =C2=A0 1fe3: =C2=A0 =C2=A0 =C2=A0 57 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0push =C2=A0 %edi
>> =C2=A0 =C2=A0 1fe4: =C2=A0 =C2=A0 =C2=A0 56 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0push =C2=A0 %esi
>> =C2=A0 =C2=A0 1fe5: =C2=A0 =C2=A0 =C2=A0 53 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0push =C2=A0 %ebx
>> =C2=A0 =C2=A0 1fe6: =C2=A0 =C2=A0 =C2=A0 83 ec 4c =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sub =C2=A0 =C2=A0$0x4c,%esp
>> =C2=A0 =C2=A0 1fe9: =C2=A0 =C2=A0 =C2=A0 89 45 c0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mov =C2=A0 =C2=A0%eax,-0x40(%ebp)
>> =C2=A0 =C2=A0 1fec: =C2=A0 =C2=A0 =C2=A0 89 55 bc =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mov =C2=A0 =C2=A0%edx,-0x44(%ebp)
>> =C2=A0 =C2=A0 1fef: =C2=A0 =C2=A0 =C2=A0 89 4d b8 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mov =C2=A0 =C2=A0%ecx,-0x48(%ebp)
>>
>> 0x110 -> 0x4c.
>>
>> Should we have to add noinline_for_stack for shrink_list?
>>
>
> Hmm. about shirnk_zone(), I don't think uninlining functions directly cal=
led
> by shrink_zone() can be a help.
> Total stack size of call-chain will be still big.

Absolutely.
But above 500 byte usage is one of hogger and uninlining is not
critical about reclaim performance. So I think we don't get any lost
than gain.

But I don't get in a hurry. adhoc approach is not good.
I hope when Mel tackles down consumption of stack in reclaim path, he
modifies this part, too.

Thanks.

> Thanks,
> -Kame
>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
