Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id DE81E900136
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 16:51:03 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <f477a147-9948-4bef-973a-1f77bd185da1@default>
Date: Tue, 13 Sep 2011 13:50:27 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V9 3/6] mm: frontswap: core frontswap functionality
References: <20110913174026.GA11298@ca-server1.us.oracle.com
 4E6FBFC4.1080901@linux.vnet.ibm.com>
In-Reply-To: <4E6FBFC4.1080901@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCH V9 3/6] mm: frontswap: core frontswap functionality
>=20
> Hey Dan,
>=20
> I get the following compile warnings:
>=20
> mm/frontswap.c: In function 'init_frontswap':
> mm/frontswap.c:264:5: warning: passing argument 4 of 'debugfs_create_size=
_t' from incompatible pointer
> type
> include/linux/debugfs.h:68:16: note: expected 'size_t *' but argument is =
of type 'long unsigned int *'
> mm/frontswap.c:266:5: warning: passing argument 4 of 'debugfs_create_size=
_t' from incompatible pointer
> type
> include/linux/debugfs.h:68:16: note: expected 'size_t *' but argument is =
of type 'long unsigned int *'
> mm/frontswap.c:268:5: warning: passing argument 4 of 'debugfs_create_size=
_t' from incompatible pointer
> type
> include/linux/debugfs.h:68:16: note: expected 'size_t *' but argument is =
of type 'long unsigned int *'
> mm/frontswap.c:270:5: warning: passing argument 4 of 'debugfs_create_size=
_t' from incompatible pointer
> type
> include/linux/debugfs.h:68:16: note: expected 'size_t *' but argument is =
of type 'long unsigned int *'

Thanks for checking on 32-bit!
=20
> size_t is platform dependent but is generally "unsigned int"
> for 32-bit and "unsigned long" for 64-bit.
>=20
> I think just typecasting these to size_t * would fix it.

Actually, I think the best fix is likely to change the variables
and the debugfs calls to u64 since even on 32-bit, the
counters may exceed 2**32 on a heavily-loaded long-running
system.

I'll give it a day or two to see if anyone else has any feedback
before I fix this for V10.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
