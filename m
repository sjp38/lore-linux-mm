Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 854AA8D0002
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 18:25:33 -0500 (EST)
Subject: Re: [PATCH 06/13] writeback: bdi write bandwidth estimation
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101117150837.a18d56c1.akpm@linux-foundation.org>
References: <20101117042720.033773013@intel.com>
	 <20101117042850.002299964@intel.com>
	 <20101117150837.a18d56c1.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 18 Nov 2010 00:24:59 +0100
Message-ID: <1290036299.2109.1288.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Li Shaohua <shaohua.li@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-17 at 15:08 -0800, Andrew Morton wrote:
> On Wed, 17 Nov 2010 12:27:26 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
>=20
> > +     w =3D min(elapsed / (HZ/100), 128UL);
>=20
> I did try setting HZ=3D10 many years ago, and the kernel blew up.
>=20
> I do recall hearing of people who set HZ very low, perhaps because
> their huge machines were seeing performance prolems when the timer tick
> went off.  Probably there's no need to do that any more.
>=20
> But still, we shouldn't hard-wire the (HZ >=3D 100) assumption if we
> don't absolutely need to, and I don't think it is absolutely needed
> here. =20

People who do cpu bring-up on very slow FPGAs also lower HZ as far as
possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
