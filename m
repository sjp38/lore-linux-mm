Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D8ABB60021B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 10:58:09 -0500 (EST)
MIME-Version: 1.0
Message-ID: <f4ab13eb-daaa-40be-82ad-691505b1f169@default>
Date: Mon, 28 Dec 2009 07:57:28 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Tmem [PATCH 0/5] (Take 3): Transcendent memory
In-Reply-To: <20091225191848.GB8438@elf.ucw.cz>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Nitin Gupta <ngupta@vflare.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, chris.mason@oracle.com, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


> From: Pavel Machek [mailto:pavel@ucw.cz]
> > > As I mentioned, I really like the idea behind tmem. All I=20
> am proposing
> > > is that we should probably explore some alternatives to=20
> achive this using
> > > some existing infrastructure in kernel.
> >=20
> > Hi Nitin --
> >=20
> > Sorry if I sounded overly negative... too busy around the holidays.
> >=20
> > I'm definitely OK with exploring alternatives.  I just think that
> > existing kernel mechanisms are very firmly rooted in the notion
> > that either the kernel owns the memory/cache or an asynchronous
> > device owns it.  Tmem falls somewhere in between and is very
>=20
> Well... compcache seems to be very similar to preswap: in preswap case
> you don't know if hypervisor will have space, in ramzswap you don't
> know if data are compressible.

Hi Pavel --

Yes there are definitely similarities too.  In fact, I started
prototyping preswap (now called frontswap) with Nitin's
compcache code.  IIRC I ran into some problems with compcache's
difficulties in dealing with failed "puts" due to dynamic
changes in size of hypervisor-available-memory.

Nitin may have addressed this in later versions of ramzswap.

One feature of frontswap which is different than ramzswap is
that frontswap acts as a "fronting store" for all configured
swap devices, including SAN/NAS swap devices.  It doesn't
need to be separately configured as a "highest priority" swap
device.  In many installations and depending on how ramzswap
is configured, this difference probably doesn't make much
difference though.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
