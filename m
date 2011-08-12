Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2255D900138
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 09:04:47 -0400 (EDT)
Subject: Re: [PATCH 2/5] writeback: dirty position control
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 12 Aug 2011 15:04:19 +0200
References: <20110806084447.388624428@intel.com>
	 <20110806094526.733282037@intel.com> <1312811193.10488.33.camel@twins>
	 <20110808141128.GA22080@localhost> <1312814501.10488.41.camel@twins>
	 <20110808230535.GC7176@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1313154259.6576.42.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2011-08-09 at 19:20 +0200, Peter Zijlstra wrote:
>=20
> Now all of the above would seem to suggest:
>=20
>   dirty_ratelimit :=3D ref_bw
>=20
> However for that you use:
>=20
>   if (pos_bw < dirty_ratelimit && ref_bw < dirty_ratelimit)
>         dirty_ratelimit =3D max(ref_bw, pos_bw);
>=20
>   if (pos_bw > dirty_ratelimit && ref_bw > dirty_ratelimit)
>         dirty_ratelimit =3D min(ref_bw, pos_bw);
>=20
> You have:
>=20
>   pos_bw =3D dirty_ratelimit * pos_ratio
>=20
> Which is ref_bw without the write_bw/dirty_bw factor, this confuses me..
> why are you ignoring the shift in output vs input rate there?=20

Could you elaborate on this primary feedback loop? Its the one part I
don't feel I actually understand well.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
