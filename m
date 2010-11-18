Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 069D16B0089
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 11:29:02 -0500 (EST)
Subject: Re: [PATCH] writeback: prevent bandwidth calculation overflow
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101118160652.GA19459@localhost>
References: <20101118065725.GB8458@localhost> <4CE537BE.6090103@redhat.com>
	 <20101118154408.GA18582@localhost> <1290096121.2109.1525.camel@laptop>
	 <20101118160652.GA19459@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 18 Nov 2010 17:29:00 +0100
Message-ID: <1290097740.2109.1527.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Li, Shaohua" <shaohua.li@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-11-19 at 00:06 +0800, Wu Fengguang wrote:
> On Fri, Nov 19, 2010 at 12:02:01AM +0800, Peter Zijlstra wrote:
> > On Thu, 2010-11-18 at 23:44 +0800, Wu Fengguang wrote:
> > > +               pause =3D HZ * pages_dirtied / (bw + 1);
> >=20
> > Shouldn't that be using something like div64_u64 ?
>=20
> OK, but a dumb question: gcc cannot handle this implicitly?

it could, but we chose not to implement the symbol it emits for these
things so as to cause pain.. that was still assuming the world of 32bit
computing was relevant and 64bit divides were expensive ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
