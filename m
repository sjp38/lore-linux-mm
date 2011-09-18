Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 036339000BD
	for <linux-mm@kvack.org>; Sun, 18 Sep 2011 10:23:50 -0400 (EDT)
Date: Sun, 18 Sep 2011 22:23:44 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 13/18] writeback: limit max dirty pause time
Message-ID: <20110918142344.GC15366@localhost>
References: <20110904015305.367445271@intel.com>
 <20110904020916.329482509@intel.com>
 <1315320726.14232.11.camel@twins>
 <20110907023505.GB13755@localhost>
 <1315822951.26517.25.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315822951.26517.25.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 12, 2011 at 06:22:31PM +0800, Peter Zijlstra wrote:
> On Wed, 2011-09-07 at 10:35 +0800, Wu Fengguang wrote:
> > So yeah, the HZ value does impact the minimal available sleep time...
> 
> There's always schedule_hrtimeout() and we could trivially add a
> io_schedule_hrtimeout() variant if you need it.

Yeah, we could do that when get done with the basic functions :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
