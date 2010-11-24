Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 494BF6B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 07:56:49 -0500 (EST)
Subject: Re: [PATCH 09/13] writeback: reduce per-bdi dirty threshold ramp
 up time
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101124123923.GB10413@localhost>
References: <20101117042720.033773013@intel.com>
	 <20101117042850.361893350@intel.com> <1290597341.2072.456.camel@laptop>
	 <20101124123923.GB10413@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 24 Nov 2010 13:56:40 +0100
Message-ID: <1290603400.2072.466.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Richard Kennedy <richard@rsk.demon.co.uk>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-24 at 20:39 +0800, Wu Fengguang wrote:
> > > @@ -125,7 +125,7 @@ static int calc_period_shift(void)
> > >     else
> > >             dirty_total =3D (vm_dirty_ratio * determine_dirtyable_mem=
ory()) /
> > >                             100;
> > > -   return 2 + ilog2(dirty_total - 1);
> > > +   return ilog2(dirty_total - 1) - 1;
> > >  }
> > > =20
> > >  /*
> >=20
> > You could actually improve upon this now that you have per-bdi bandwidt=
h
> > estimations, simply set the period to (seconds * bandwidth) to get
> > convergence in @seconds.
>=20
> I'd like to, but there is the global vs. bdi discrepancy to be
> addressed first :)
>=20
> How about doing this simple fix first, and then revisit doing per-bdi
> vm_dirties after the bandwidth estimation goes upstream?=20

Sure

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
