Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 67F5F900137
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 06:32:46 -0400 (EDT)
Subject: Re: [PATCH 2/5] writeback: dirty position control
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 09 Aug 2011 12:32:19 +0200
In-Reply-To: <20110808230535.GC7176@localhost>
References: <20110806084447.388624428@intel.com>
	 <20110806094526.733282037@intel.com> <1312811193.10488.33.camel@twins>
	 <20110808141128.GA22080@localhost> <1312814501.10488.41.camel@twins>
	 <20110808230535.GC7176@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1312885939.22367.73.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2011-08-09 at 07:05 +0800, Wu Fengguang wrote:
> This is the more meaningful view :)
>=20
>                     origin - dirty
>         pos_ratio =3D --------------
>                     origin - goal=20

> which comes from the below [*] control line, so that when (dirty =3D=3D g=
oal),
> pos_ratio =3D=3D 1.0:

OK, so basically you want a linear function for which:

f(goal) =3D 1 and has a root somewhere > goal.

(that one line is much more informative than all your graphs put
together, one can start from there and derive your function)

That does indeed get you the above function, now what does it mean?

> + *  When the number of dirty pages go higher/lower than the setpoint, th=
e dirty
> + *  position ratio (and hence dirty rate limit) will be decreased/increa=
sed to
> + *  bring the dirty pages back to the setpoint.

(you seem inconsistent with your terminology, I think goal and setpoint
are interchanged? I looked up set point and its a term from control
system theory, so I'll chalk that up to my own ignorance..)

Ok, so higher dirty -> lower position ration -> lower dirty rate (and
the inverse), now what does that do...

/me goes read other patches in search of more clues.. I'm starting to
dislike graphs.. why not simply state where those things come from,
that's much easier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
