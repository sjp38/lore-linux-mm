Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8DA6B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 08:42:07 -0500 (EST)
Subject: Re: [PATCH 06/13] writeback: bdi write bandwidth estimation
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101124132012.GA12117@localhost>
References: <20101117042720.033773013@intel.com>
	 <20101117042850.002299964@intel.com> <1290596732.2072.450.camel@laptop>
	 <20101124121046.GA8333@localhost> <1290603047.2072.465.camel@laptop>
	 <20101124131437.GE10413@localhost>  <20101124132012.GA12117@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 24 Nov 2010 14:42:09 +0100
Message-ID: <1290606129.2072.467.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Li, Shaohua" <shaohua.li@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-24 at 21:20 +0800, Wu Fengguang wrote:
> >         (jiffies - bdi->write_bandwidth_update_time < elapsed)
>=20
> this will be true if someone else has _done_ overlapped estimation,
> otherwise it will equal:
>=20
>         jiffies - bdi->write_bandwidth_update_time =3D=3D elapsed
>=20
> Sorry the comment needs updating.=20

Right, but its racy as hell..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
