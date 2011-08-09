Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC3F6B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 11:04:08 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <ce8cba73-ec3c-42ae-849a-11db1df8ffa3@default>
Date: Tue, 9 Aug 2011 08:03:43 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Subject: [PATCH V6 1/4] mm: frontswap: swap data structure
 changes
References: <20110808204555.GA15850@ca-server1.us.oracle.com
 4E414320020000780005057E@nat28.tlf.novell.com>
In-Reply-To: <4E414320020000780005057E@nat28.tlf.novell.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Beulich <JBeulich@novell.com>
Cc: hannes@cmpxchg.org, jackdachef@gmail.com, hughd@google.com, jeremy@goop.org, npiggin@kernel.dk, linux-mm@kvack.org, akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, Chris Mason <chris.mason@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Kurt Hackel <kurt.hackel@oracle.com>, riel@redhat.com, ngupta@vflare.org, linux-kernel@vger.kernel.org, matthew@wil.cx

> > --- linux/include/linux/swap.h=092011-08-08 08:19:25.880690134 -0600
> > +++ frontswap/include/linux/swap.h=092011-08-08 08:59:03.952691415 -060=
0
> > @@ -194,6 +194,8 @@ struct swap_info_struct {
> >  =09struct block_device *bdev;=09/* swap device or bdev of swap file */
> >  =09struct file *swap_file;=09=09/* seldom referenced */
> >  =09unsigned int old_block_size;=09/* seldom referenced */
>=20
> #ifdef CONFIG_FRONTSWAP
>=20
> > +=09unsigned long *frontswap_map;=09/* frontswap in-use, one bit per pa=
ge */
> > +=09unsigned int frontswap_pages;=09/* frontswap pages in-use counter *=
/
>=20
>=20
> #endif
>=20
> (to eliminate any overhead with that config option unset)
>=20
> Jan

Hi Jan --

Thanks for the review!

As noted in the commit comment, if these structure elements are
not put inside an #ifdef CONFIG_FRONTSWAP, it becomes
unnecessary to clutter the core swap code with several ifdefs.
The cost is one pointer and one unsigned int per allocated
swap device (often no more than one swap device per system),
so the code clarity seemed more important than the tiny
additional runtime space cost.

Do you disagree?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
