Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DA8A68D0002
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 18:08:55 -0500 (EST)
Date: Wed, 17 Nov 2010 15:08:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 06/13] writeback: bdi write bandwidth estimation
Message-Id: <20101117150837.a18d56c1.akpm@linux-foundation.org>
In-Reply-To: <20101117042850.002299964@intel.com>
References: <20101117042720.033773013@intel.com>
	<20101117042850.002299964@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Li Shaohua <shaohua.li@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010 12:27:26 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> +	w = min(elapsed / (HZ/100), 128UL);

I did try setting HZ=10 many years ago, and the kernel blew up.

I do recall hearing of people who set HZ very low, perhaps because
their huge machines were seeing performance prolems when the timer tick
went off.  Probably there's no need to do that any more.

But still, we shouldn't hard-wire the (HZ >= 100) assumption if we
don't absolutely need to, and I don't think it is absolutely needed
here.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
