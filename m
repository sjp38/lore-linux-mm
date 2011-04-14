Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9DA53900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 08:24:59 -0400 (EDT)
Message-ID: <858878.89812.qm@web162015.mail.bf1.yahoo.com>
Date: Thu, 14 Apr 2011 05:24:56 -0700 (PDT)
From: Pintu Agarwal <pintu_agarwal@yahoo.com>
Subject: Re: Regarding memory fragmentation using malloc....
In-Reply-To: <op.vtxb92f73l0zgt@mnazarewicz-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>, Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <eric.dumazet@gmail.com>, Changli Gao <xiaosuo@gmail.com>, Jiri Slaby <jslaby@suse.cz>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>

Hello Mr. Michal,

Thanks for your comments.
Sorry. There was a small typo in my last sentence (mitigating not *migitati=
ng* memory fragmentation)
That means how can I measure the memory fragmentation either from user spac=
e or from kernel space.
Is there a way to measure the amount of memory fragmentation in linux?
Can you provide me some references for that?


Thanks,
Pintu



--- On Thu, 4/14/11, Michal Nazarewicz <mina86@mina86.com> wrote:

> From: Michal Nazarewicz <mina86@mina86.com>
> Subject: Re: Regarding memory fragmentation using malloc....
> To: "Am=E9rico Wang" <xiyou.wangcong@gmail.com>, "Pintu Agarwal" <pintu_a=
garwal@yahoo.com>
> Cc: "Andrew Morton" <akpm@linux-foundation.org>, "Eric Dumazet" <eric.dum=
azet@gmail.com>, "Changli Gao" <xiaosuo@gmail.com>, "Jiri Slaby" <jslaby@su=
se.cz>, "azurIt" <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@=
kvack.org, linux-fsdevel@vger.kernel.org, "Jiri Slaby" <jirislaby@gmail.com=
>
> Date: Thursday, April 14, 2011, 5:47 AM
> On Thu, 14 Apr 2011 08:44:50 +0200,
> Pintu Agarwal <pintu_agarwal@yahoo.com>
> wrote:
> > As I can understand from your comments that, malloc
> from user space will not have much impact on memory
> fragmentation.
>=20
> It has an impact, just like any kind of allocation, it just
> don't care about
> fragmentation of physical memory.=A0 You can have only
> 0-order pages and
> successfully allocate megabytes of memory with malloc().
>=20
> > Will the memory fragmentation be visible if I do
> kmalloc from
> > the kernel module????
>=20
> It will be more visible in the sense that if you allocate 8
> KiB, kernel will
> have to find 8 KiB contiguous physical memory (ie. 1-order
> page).
>=20
> >> No.=A0 When you call malloc() only virtual
> address space is allocated.
> >> The actual allocation of physical space occurs
> when user space accesses
> >> the memory (either reads or writes) and it happens
> page at a time.
> >=20
> > Here, if I do memset then I am accessing the
> memory...right? That I am doing already in my sample
> program.
>=20
> Yes.=A0 But note that even though it's a single memset()
> call, you are
> accessing page at a time and kernel is allocating page at a
> time.
>=20
> On some architectures (not ARM) you could access two pages
> with a single
> instructions but I think that would result in two page
> faults anyway.=A0 I
> might be wrong though, the details are not important
> though.
>=20
> >> what really happens is that kernel allocates the
> 0-order
> >> pages and when
> >> it runs out of those, splits a 1-order page into
> two
> >> 0-order pages and
> >> takes one of those.
> >=20
> > Actually, if I understand buddy allocator, it
> allocates pages from top to bottom.
>=20
> No.=A0 If you want to allocate a single 0-order page,
> buddy looks for a
> a free 0-order page.=A0 If one is not found, it will
> look for 1-order page
> and split it.=A0 This goes up till buddy reaches
> (MAX_ORDER-1)-page.
>=20
> > Is the memory fragmentation is always a cause of the
> kernel space program and not user space at all?
>=20
> Well, no.=A0 If you allocate memory in user space,
> kernel will have to
> allocate physical memory and *every* allocation may
> contribute to
> fragmentation.=A0 The point is, that all allocations
> from user-space are
> single-page allocations even if you malloc() MiBs of
> memory.
>=20
> > Can you provide me with some references for migitating
> memory fragmentation in linux?
>=20
> I'm not sure what you mean by that.
>=20
> --Best regards,=A0 =A0 =A0 =A0 =A0 =A0
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0
> =A0 =A0 =A0 =A0 =A0 =A0=A0=A0_=A0
> =A0=A0=A0_
> .o. | Liege of Serenely Enlightened Majesty of=A0 =A0
> =A0 o' \,=3D./ `o
> ..o | Computer Science,=A0 Michal "mina86"
> Nazarewicz=A0 =A0 (o o)
> ooo +-----<email/xmpp: mnazarewicz@google.com>-----ooO--(_)--Ooo--
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm'
> in
> the body to majordomo@kvack.org.=A0
> For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org">
> email@kvack.org
> </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
