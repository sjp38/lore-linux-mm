Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 109E36B0169
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 13:08:39 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <cf3e6497-c77f-47eb-a35e-360ea68ade85@default>
Date: Mon, 22 Aug 2011 10:08:08 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Subject: [PATCH V6 1/4] mm: frontswap: swap data structure
 changes
References: <20110808204555.GA15850@ca-server1.us.oracle.com>
 <4E414320020000780005057E@nat28.tlf.novell.com><4E414320020000780005057E@nat28.tlf.novell.com>
 <ce8cba73-ec3c-42ae-849a-11db1df8ffa3@default
 4E4179D90200007800050676@nat28.tlf.novell.com>
In-Reply-To: <4E4179D90200007800050676@nat28.tlf.novell.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Beulich <JBeulich@novell.com>
Cc: hannes@cmpxchg.org, jackdachef@gmail.com, hughd@google.com, jeremy@goop.org, npiggin@kernel.dk, linux-mm@kvack.org, akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, Chris Mason <chris.mason@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Kurt Hackel <kurt.hackel@oracle.com>, riel@redhat.com, ngupta@vflare.org, linux-kernel@vger.kernel.org, matthew@wil.cx

> From: Jan Beulich [mailto:JBeulich@novell.com]
> Sent: Tuesday, August 09, 2011 10:18 AM
> To: Dan Magenheimer
> Cc: hannes@cmpxchg.org; jackdachef@gmail.com; hughd@google.com; jeremy@go=
op.org; npiggin@kernel.dk;
> linux-mm@kvack.org; akpm@linux-foundation.org; sjenning@linux.vnet.ibm.co=
m; Chris Mason; Konrad Wilk;
> Kurt Hackel; riel@redhat.com; ngupta@vflare.org; linux-kernel@vger.kernel=
.org; matthew@wil.cx
> Subject: RE: Subject: [PATCH V6 1/4] mm: frontswap: swap data structure c=
hanges
>=20
> >>> On 09.08.11 at 17:03, Dan Magenheimer <dan.magenheimer@oracle.com> wr=
ote:
> >> > --- linux/include/linux/swap.h=092011-08-08 08:19:25.880690134 -0600
> >> > +++ frontswap/include/linux/swap.h=092011-08-08 08:59:03.952691415 -=
0600
> >> > @@ -194,6 +194,8 @@ struct swap_info_struct {
> >> >  =09struct block_device *bdev;=09/* swap device or bdev of swap file=
 */
> >> >  =09struct file *swap_file;=09=09/* seldom referenced */
> >> >  =09unsigned int old_block_size;=09/* seldom referenced */
> >>
> >> #ifdef CONFIG_FRONTSWAP
> >>
> >> > +=09unsigned long *frontswap_map;=09/* frontswap in-use, one bit per=
 page */
> >> > +=09unsigned int frontswap_pages;=09/* frontswap pages in-use counte=
r */
> >>
> >> #endif
> >>
> >> (to eliminate any overhead with that config option unset)
> >>
> >> Jan
> >
> > Hi Jan --
> >
> > Thanks for the review!
> >
> > As noted in the commit comment, if these structure elements are
> > not put inside an #ifdef CONFIG_FRONTSWAP, it becomes
> > unnecessary to clutter the core swap code with several ifdefs.
> > The cost is one pointer and one unsigned int per allocated
> > swap device (often no more than one swap device per system),
> > so the code clarity seemed more important than the tiny
> > additional runtime space cost.
> >
> > Do you disagree?
>=20
> Not necessarily - I just know that in other similar occasions (partly
> internally to our company) I was asked to make sure turned off
> features would not leave *any* run time foot print whatsoever.
>=20
> Jan

Hi Jan --

With two extra static inlines in frontswap.h (frontswap_map_get()
and frontswap_map_set(), I've managed to both avoid the extra swap struct
members for frontswap_map and frontswap_pages when CONFIG_FRONTSWAP is
disabled AND avoid the #ifdef CONFIG_FRONTSWAP clutter in swapfile.h.

I'll post a V7 soon... let me know what you think!

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
