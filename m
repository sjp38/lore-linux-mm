Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C1E5F6B00EE
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 11:03:20 -0400 (EDT)
Subject: Re: [PATCH 02/18] writeback: dirty position control
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 05 Sep 2011 17:02:59 +0200
In-Reply-To: <20110904020914.848566742@intel.com>
References: <20110904015305.367445271@intel.com>
	 <20110904020914.848566742@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1315234979.3191.4.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:
> + * (o) bdi control lines
> + *
> + * The control lines for the global/bdi setpoints both stretch up to @li=
mit.
> + * The below figure illustrates the main bdi control line with an auxili=
ary
> + * line extending it to @limit.
> + *
> + *   o
> + *     o
> + *       o                                      [o] main control line
> + *         o                                    [*] auxiliary control li=
ne
> + *           o
> + *             o
> + *               o
> + *                 o
> + *                   o
> + *                     o
> + *                       o--------------------- balance point, rate scal=
e =3D 1
> + *                       | o
> + *                       |   o
> + *                       |     o
> + *                       |       o
> + *                       |         o
> + *                       |           o
> + *                       |             o------- connect point, rate scal=
e =3D 1/2
> + *                       |               .*
> + *                       |                 .   *
> + *                       |                   .      *
> + *                       |                     .         *
> + *                       |                       .           *
> + *                       |                         .              *
> + *                       |                           .                 *
> + *  [--------------------+-----------------------------.----------------=
----*]
> + *  0              bdi_setpoint                    x_intercept          =
 limit
> + *
> + * The auxiliary control line allows smoothly throttling bdi_dirty down =
to
> + * normal if it starts high in situations like
> + * - start writing to a slow SD card and a fast disk at the same time. T=
he SD
> + *   card's bdi_dirty may rush to many times higher than bdi_setpoint.
> + * - the bdi dirty thresh drops quickly due to change of JBOD workload=
=20

In light of the global control thing already having a hard stop at
limit, what's the point of the auxiliary line? Why not simply run the
bdi control between [0.5, 1.5] and leave it at that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
