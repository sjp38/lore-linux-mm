Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E8EF26B0092
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 14:31:35 -0500 (EST)
Subject: Re: [PATCH 01/35] writeback: enabling gate limit for light dirtied
 bdi
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110113034401.GB7840@localhost>
References: <20101213144646.341970461@intel.com>
	 <20101213150326.480108782@intel.com> <20110112214303.GC14260@quack.suse.cz>
	 <20110113034401.GB7840@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 13 Jan 2011 20:26:10 +0100
Message-ID: <1294946770.30950.19.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2011-01-13 at 11:44 +0800, Wu Fengguang wrote:
> When testing 10-disk JBOD setup, I
> find that bdi_dirty_limit fluctuations too much. So I'm considering
> use global_dirty_limit as control target.=20

Is this because the bandwidth is equal or larger than the dirty period?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
