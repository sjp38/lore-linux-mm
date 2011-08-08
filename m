Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C64236B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 10:42:00 -0400 (EDT)
Subject: Re: [PATCH 2/5] writeback: dirty position control
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 08 Aug 2011 16:41:41 +0200
In-Reply-To: <20110808141128.GA22080@localhost>
References: <20110806084447.388624428@intel.com>
	 <20110806094526.733282037@intel.com> <1312811193.10488.33.camel@twins>
	 <20110808141128.GA22080@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1312814501.10488.41.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 2011-08-08 at 22:11 +0800, Wu Fengguang wrote:
> @@ -538,11 +538,6 @@ static unsigned long bdi_position_ratio(
>         goal =3D thresh - thresh / DIRTY_SCOPE;
>         origin =3D 4 * thresh;
> =20
> -       if (unlikely(origin < limit && dirty > (goal + origin) / 2)) {
> -               origin =3D limit;                 /* auxiliary control li=
ne */
> -               goal =3D (goal + origin) / 2;
> -               pos_ratio >>=3D 1;
> -       }
>         pos_ratio =3D origin - dirty;
>         pos_ratio <<=3D BANDWIDTH_CALC_SHIFT;
>         do_div(pos_ratio, origin - goal + 1);=20

So basically, pos_ratio =3D (4t - d) / (25/8)t, which if I'm not mistaken
comes out at 32/25 - 8d/25t. Which simply doesn't make sense at all.=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
