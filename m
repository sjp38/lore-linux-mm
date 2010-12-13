Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6FE136B0088
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 07:39:32 -0500 (EST)
Subject: Re: [PATCH 00/47] IO-less dirty throttling v3
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101213114911.GA2232@localhost>
References: <20101213064249.648862451@intel.com>
	 <1292239631.6803.186.camel@twins>  <20101213114911.GA2232@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 13 Dec 2010 13:38:14 +0100
Message-ID: <1292243894.6803.201.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-12-13 at 19:49 +0800, Wu Fengguang wrote:
> > Reviewing is lots easier if the patches present logical steps. The
> > presented series will have us looking back and forth, review patch, fin=
d
> > bugs, then scan fwd to see if the bug has been solved, etc..
>=20
> Good suggestion. Sorry I did have the plan to fold them at some later
> time.  I'll do a new version to fold the patches 16-25.  26-31 will be
> retained since they are logical enhancements that do not involve
> back-and-forth changes. 12 will be removed as it seems not absolutely
> necessary -- let the users do whatever they feel OK, even if it means
> make the throttling algorithms work in some suboptimal condition.
>=20

Thanks, much appreciated! I'll await this new series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
