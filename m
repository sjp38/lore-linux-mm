Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 178436B01AF
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 20:12:15 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <a9f0652d-7607-4e3f-a453-b37a1b0b4d94@default>
Date: Wed, 2 Jun 2010 17:10:36 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V2 1/4] Frontswap (was Transcendent Memory): swap data
 structure changes
References: <20100528174041.GA28176@ca-server1.us.oracle.com
 20100602122910.71f981e8.akpm@linux-foundation.org>
In-Reply-To: <20100602122910.71f981e8.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, riel@redhat.com, avi@redhat.com, pavel@ucw.cz, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

> > --- linux-2.6.34/include/linux/swap.h=092010-05-16 15:17:36.000000000
> -0600
> > +++ linux-2.6.34-frontswap/include/linux/swap.h=092010-05-24
> 10:13:41.000000000 -0600
> > @@ -182,6 +182,8 @@ struct swap_info_struct {
> >  =09struct block_device *bdev;=09/* swap device or bdev of swap file
> */
> >  =09struct file *swap_file;=09=09/* seldom referenced */
> >  =09unsigned int old_block_size;=09/* seldom referenced */
> > +=09unsigned long *frontswap_map;=09/* frontswap in-use, one bit per
> page */
> > +=09unsigned int frontswap_pages;=09/* frontswap pages in-use counter
> */
>=20
> Is a 32-bit uint large enough?  Maybe there are other things in swap
> which restrict us to less than 16TB, dunno.

Yes, the same data structure has "unsigned int pages" which is
the "total of usable pages" in the swap device.  If/when
"pages" changes to an unsigned long (or long long), then
"frontswap_pages" should change also.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
