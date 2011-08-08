Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 355C76B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 09:46:56 -0400 (EDT)
Subject: Re: [PATCH 2/5] writeback: dirty position control
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 08 Aug 2011 15:46:33 +0200
In-Reply-To: <20110806094526.733282037@intel.com>
References: <20110806084447.388624428@intel.com>
	 <20110806094526.733282037@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1312811193.10488.33.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, 2011-08-06 at 16:44 +0800, Wu Fengguang wrote:
> +static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
> +                                       unsigned long thresh,
> +                                       unsigned long dirty,
> +                                       unsigned long bdi_thresh,
> +                                       unsigned long bdi_dirty)
> +{
> +       unsigned long limit =3D hard_dirty_limit(thresh);
> +       unsigned long origin;
> +       unsigned long goal;
> +       unsigned long long span;
> +       unsigned long long pos_ratio;   /* for scaling up/down the rate l=
imit */
> +
> +       if (unlikely(dirty >=3D limit))
> +               return 0;
> +
> +       /*
> +        * global setpoint
> +        */
> +       goal =3D thresh - thresh / DIRTY_SCOPE;
> +       origin =3D 4 * thresh;
> +
> +       if (unlikely(origin < limit && dirty > (goal + origin) / 2)) {
> +               origin =3D limit;                 /* auxiliary control li=
ne */
> +               goal =3D (goal + origin) / 2;
> +               pos_ratio >>=3D 1;=20

use before init?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
