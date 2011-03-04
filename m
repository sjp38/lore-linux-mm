Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4058D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 09:42:05 -0500 (EST)
Subject: Re: [PATCH 09/27] nfs: writeback pages wait queue
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110304143838.GA11504@localhost>
References: <20110303064505.718671603@intel.com>
	 <20110303074949.809203319@intel.com> <1299168481.1310.56.camel@laptop>
	 <20110304020157.GB7976@localhost> <1299229843.2428.13484.camel@twins>
	 <1299230795.2428.13486.camel@twins>  <20110304143838.GA11504@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 04 Mar 2011 15:41:13 +0100
Message-ID: <1299249673.24454.5.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Chris Mason <chris.mason@oracle.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 2011-03-04 at 22:38 +0800, Wu Fengguang wrote:
> Sorry for being ignorance on the memory barriers..

n/p, everybody who encounters them seems to be a bit confused at first
and a lot more confused later :-)

> The below patch removes the unnecessary smp_mb__after_clear_bit().=20

OK, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
