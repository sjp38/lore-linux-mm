Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6126B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 05:04:46 -0400 (EDT)
Subject: Re: [PATCH 2/5] writeback: dirty position control
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 26 Aug 2011 11:04:29 +0200
In-Reply-To: <20110826001846.GA6118@localhost>
References: <20110808230535.GC7176@localhost>
	 <1313154259.6576.42.camel@twins> <20110812142020.GB17781@localhost>
	 <1314027488.24275.74.camel@twins> <20110823034042.GC7332@localhost>
	 <1314093660.8002.24.camel@twins> <20110823141504.GA15949@localhost>
	 <20110823174757.GC15820@redhat.com> <20110824001257.GA6349@localhost>
	 <1314202378.6925.48.camel@twins> <20110826001846.GA6118@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1314349469.26922.24.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 2011-08-26 at 08:18 +0800, Wu Fengguang wrote:
> On Thu, Aug 25, 2011 at 12:12:58AM +0800, Peter Zijlstra wrote:
> > On Wed, 2011-08-24 at 08:12 +0800, Wu Fengguang wrote:

> > > Put (6) into (4), we get
> > >=20
> > >         balanced_rate_(i+1) =3D balanced_rate_(i) * 2
> > >                             =3D (write_bw / N) * 2
> > >=20
> > > That means, any position imbalance will lead to balanced_rate
> > > estimation errors if we follow (4). Whereas if (1)/(5) is used, we
> > > always get the right balanced dirty ratelimit value whether or not
> > > (pos_ratio =3D=3D 1.0), hence make the rate estimation independent(*)=
 of
> > > dirty position control.
> > >=20
> > > (*) independent as in real values, not the seemingly relations in equ=
ation
> >=20
> >=20
> > The assumption here is that N is a constant.. in the above case
> > pos_ratio would eventually end up at 1 and things would be good again. =
I
> > see your argument about oscillations, but I think you can introduce
> > similar effects by varying N.
>=20
> Yeah, it's very possible for N to change over time, in which case
> balanced_rate will adapt to new N in similar way.

Gah.. but but but, that gives the same stuff as your (6)+(4). Why won't
you accept that for pos_ratio but you don't mind for N ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
