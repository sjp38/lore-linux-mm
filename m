Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3E19E900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 11:48:37 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <4be6abb6-7b82-4e64-9e27-cd0fe0c1e1b1@default>
Date: Mon, 29 Aug 2011 08:47:59 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Subject: [PATCH V7 2/4] mm: frontswap: core code
References: <20110823145815.GA23190@ca-server1.us.oracle.com>
 <20110825150532.a4d282b1.kamezawa.hiroyu@jp.fujitsu.com>
 <d0b4c414-e90f-4ae0-9b70-fd5b54d2b011@default
 20110826091619.1ad27e9c.kamezawa.hiroyu@jp.fujitsu.com
 a2fc3885-b98d-4918-afcc-5eac083c7eb0@default>
In-Reply-To: <a2fc3885-b98d-4918-afcc-5eac083c7eb0@default>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com

> > My concern was race in counters. Even you allow race in frontswap_succ_=
puts++,
> >
> > Don't you need some lock for
> > =09sis->frontswap_pages++
> > =09sis->frontswap_pages--
>=20
> Hmmm... OK, you've convinced me.  If this counter should be one and
> a race leaves it as zero, I think data corruption could result on
> a swapoff or partial swapoff.  And after thinking about it, I
> think I also need to check for locking on frontswap_set/clear
> as I don't think these bitfield modifiers are atomic.
>=20
> Thanks for pointing this out.  Good catch!  I will need to
> play with this and test it so probably will not submit V8 until
> next week as today is a vacation day for me.

Silly me: Of course set_bit and clear_bit ARE atomic.  I will
post V8 later today with the only changes being frontswap_pages
is now a type atomic_t.

Thanks again for catching this, Kame!

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
