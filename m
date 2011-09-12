Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 99DA26B0252
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 06:28:39 -0400 (EDT)
Subject: Re: [PATCH 14/18] writeback: control dirty pause time
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 12 Sep 2011 12:28:05 +0200
In-Reply-To: <20110907020214.GA13755@localhost>
References: <20110904015305.367445271@intel.com>
	 <20110904020916.460538138@intel.com> <1315324285.14232.16.camel@twins>
	 <20110907020214.GA13755@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1315823285.26517.27.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 2011-09-07 at 10:02 +0800, Wu Fengguang wrote:
> > also, do the two other line segments connect on the transition
> > point?
>=20
> I guess we can simply unify the other two formulas into one:
>=20
>         } else if (period <=3D max_pause / 4 &&
>                  pages_dirtied >=3D current->nr_dirtied_pause) {
>                 current->nr_dirtied_pause =3D clamp_val(
> =3D=3D>                                     dirty_ratelimit * (max_pause =
/ 2) / HZ,
>                                         pages_dirtied + pages_dirtied / 8=
,
>                                         pages_dirtied * 4);
>         } else if (pause >=3D max_pause) {
>                 current->nr_dirtied_pause =3D 1 | clamp_val(
> =3D=3D>                                     dirty_ratelimit * (max_pause =
/ 2) / HZ,
>                                         pages_dirtied / 4,
>                                         pages_dirtied - pages_dirtied / 8=
);
>         }=20


There's still the clamping, that combined with the various conditionals
make it very hard to tell if the functions are connected or jump around.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
