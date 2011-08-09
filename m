Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7C729900137
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 12:17:09 -0400 (EDT)
Message-Id: <4E4179D90200007800050676@nat28.tlf.novell.com>
Date: Tue, 09 Aug 2011 17:18:01 +0100
From: "Jan Beulich" <JBeulich@novell.com>
Subject: RE: Subject: [PATCH V6 1/4] mm: frontswap: swap data structure
	 changes
References: <20110808204555.GA15850@ca-server1.us.oracle.com
 4E414320020000780005057E@nat28.tlf.novell.com><4E414320020000780005057E@nat28.tlf.novell.com>
 <ce8cba73-ec3c-42ae-849a-11db1df8ffa3@default>
In-Reply-To: <ce8cba73-ec3c-42ae-849a-11db1df8ffa3@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: hannes@cmpxchg.org, jackdachef@gmail.com, hughd@google.com, jeremy@goop.org, npiggin@kernel.dk, linux-mm@kvack.org, akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, Chris Mason <chris.mason@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Kurt Hackel <kurt.hackel@oracle.com>, riel@redhat.com, ngupta@vflare.org, linux-kernel@vger.kernel.org, matthew@wil.cx

>>> On 09.08.11 at 17:03, Dan Magenheimer <dan.magenheimer@oracle.com> =
wrote:
>> > --- linux/include/linux/swap.h	2011-08-08 08:19:25.880690134 =
-0600
>> > +++ frontswap/include/linux/swap.h	2011-08-08 08:59:03.952691415 =
-0600
>> > @@ -194,6 +194,8 @@ struct swap_info_struct {
>> >  	struct block_device *bdev;	/* swap device or bdev of swap =
file */
>> >  	struct file *swap_file;		/* seldom referenced */
>> >  	unsigned int old_block_size;	/* seldom referenced */
>>=20
>> #ifdef CONFIG_FRONTSWAP
>>=20
>> > +	unsigned long *frontswap_map;	/* frontswap in-use, one bit per =
page */
>> > +	unsigned int frontswap_pages;	/* frontswap pages in-use counter =
*/
>>=20
>>=20
>> #endif
>>=20
>> (to eliminate any overhead with that config option unset)
>>=20
>> Jan
>=20
> Hi Jan --
>=20
> Thanks for the review!
>=20
> As noted in the commit comment, if these structure elements are
> not put inside an #ifdef CONFIG_FRONTSWAP, it becomes
> unnecessary to clutter the core swap code with several ifdefs.
> The cost is one pointer and one unsigned int per allocated
> swap device (often no more than one swap device per system),
> so the code clarity seemed more important than the tiny
> additional runtime space cost.
>=20
> Do you disagree?

Not necessarily - I just know that in other similar occasions (partly
internally to our company) I was asked to make sure turned off
features would not leave *any* run time foot print whatsoever.

Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
