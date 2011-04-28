Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5E5466B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 17:12:34 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <1304020767.2598.21.camel@mulgrave.site>
References: <1303990590.2081.9.camel@lenovo>
	 <20110428135228.GC1696@quack.suse.cz> <20110428140725.GX4658@suse.de>
	 <1304000714.2598.0.camel@mulgrave.site> <20110428150827.GY4658@suse.de>
	 <1304006499.2598.5.camel@mulgrave.site>
	 <1304009438.2598.9.camel@mulgrave.site>
	 <1304009778.2598.10.camel@mulgrave.site> <20110428171826.GZ4658@suse.de>
	 <1304015436.2598.19.camel@mulgrave.site>  <20110428192104.GA4658@suse.de>
	 <1304020767.2598.21.camel@mulgrave.site>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Apr 2011 16:12:24 -0500
Message-ID: <1304025145.2598.24.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, mgorman@novell.com

On Thu, 2011-04-28 at 14:59 -0500, James Bottomley wrote:
> Actually, talking to Chris, I think I can get the system up using
> init=/bin/bash without systemd, so I can try the no cgroup config.

OK, so a non-PREEMPT non-CGROUP kernel has survived three back to back
runs of untar without locking or getting kswapd pegged, so I'm pretty
certain this is cgroups related.  The next steps are to turn cgroups
back on but try disabling the memory and IO controllers.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
