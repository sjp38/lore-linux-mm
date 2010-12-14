Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A7AA56B0089
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 13:55:31 -0500 (EST)
Subject: Re: [PATCH 16/35] writeback: increase min pause time on concurrent
 dirtiers
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <14658.1292352152@localhost>
References: <20101213144646.341970461@intel.com>
	 <20101213150328.284979629@intel.com> <15881.1292264611@localhost>
	 <20101214065133.GA6940@localhost>  <14658.1292352152@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 14 Dec 2010 19:55:08 +0100
Message-ID: <1292352908.13513.376.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Valdis.Kletnieks@vt.edu
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-12-14 at 13:42 -0500, Valdis.Kletnieks@vt.edu wrote:
> On Tue, 14 Dec 2010 14:51:33 +0800, Wu Fengguang said:
>=20
> > > > +	/* (N * 10ms) on 2^N concurrent tasks */
> > > > +	t =3D (hi - lo) * (10 * HZ) / 1024;
> > >=20
> > > Either I need more caffeine, or the comment doesn't match the code
> > > if HZ !=3D 1000?
> >=20
> > The "ms" in the comment may be confusing, but the pause time (t) is
> > measured in jiffies :)  Hope the below patch helps.
>=20
> No, I meant that 10 * HZ evaluates to different numbers depending what
> the CONFIG_HZ parameter is set to - 100, 250, 1000, or some other
> custom value.  Does this code behave correctly on a CONFIG_HZ=3D100 kerne=
l?

10*HZ =3D 10 seconds
(10*HZ) / 1024 ~=3D 10 milliseconds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
