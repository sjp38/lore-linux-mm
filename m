Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D57AE6B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 12:16:51 -0400 (EDT)
Subject: Re: [PATCH 15/18] writeback: charge leaked page dirties to active
 tasks
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 06 Sep 2011 18:16:36 +0200
In-Reply-To: <20110904020916.588150387@intel.com>
References: <20110904015305.367445271@intel.com>
	 <20110904020916.588150387@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1315325796.14232.20.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:
> The solution is to charge the pages dirtied by the exited gcc to the
> other random gcc/dd instances.

random dirtying task, seeing it lacks a !strcmp(t->comm, "gcc") || !
strcmp(t->comm, "dd") clause.

>  It sounds not perfect, however should
> behave good enough in practice.=20

Seeing as that throttled tasks aren't actually running so those that are
running are more likely to pick it up and get throttled, therefore
promoting an equal spread.. ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
