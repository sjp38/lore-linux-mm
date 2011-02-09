Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6A28D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 11:58:42 -0500 (EST)
MIME-Version: 1.0
Message-ID: <d21f1970-225e-4f5a-9e72-97991bd1a2c0@default>
Date: Wed, 9 Feb 2011 08:55:50 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V1 1/3] drivers/staging: kztmem: in-kernel tmem code
References: <20110118171950.GA20460@ca-server1.us.oracle.com
 20110207160253.GA18151@dumpdata.com>
In-Reply-To: <20110207160253.GA18151@dumpdata.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Wilk <konrad.wilk@oracle.com>
Cc: gregkh@suse.de, Chris Mason <chris.mason@oracle.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, riel@redhat.com, mel@csn.ul.ie, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, sfr@canb.auug.org.au, wfg@mail.ustc.edu.cn, tytso@mit.edu, viro@ZenIV.linux.org.uk, hughd@google.com, hannes@cmpxchg.org

> From: Konrad Rzeszutek Wilk
> Subject: Re: [PATCH V1 1/3] drivers/staging: kztmem: in-kernel tmem
> code
>=20
> On Tue, Jan 18, 2011 at 09:19:50AM -0800, Dan Magenheimer wrote:
> > [PATCH V1 1/3] drivers/staging: kztmem: in-kernel tmem code
>=20
> Hey Dan,
>=20
> I never finished this review, but sending my fragmented comments
> in case the one you posted has overlap.

Thanks Konrad for the thorough review!  I'll fix the nits at the
next version of zcache but will assume (unless you feel otherwise)
that none of these is a showstopper for zcache to be accepted as
a staging driver.

To answer your one question:

> persistent and ephemeral pages can both be in PAM space?

Yes, persistent vs ephemeral is an attribute of the
"struct tmem_pool" and a pointer to the pool is passed
to all PAM callbacks.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
