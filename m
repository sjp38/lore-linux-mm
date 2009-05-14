Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B52EA6B0087
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:14:38 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id AD8E282C397
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:27:37 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id n5xVntCwTV0c for <linux-mm@kvack.org>;
	Thu, 14 May 2009 16:27:37 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C83FF82C396
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:27:32 -0400 (EDT)
Date: Thu, 14 May 2009 16:14:31 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH -mm] vmscan: protect a fraction of file backed mapped
 pages from reclaim
In-Reply-To: <20090513084306.5874.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0905141612100.15881@qirst.com>
References: <20090512120002.D616.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0905121650090.14226@qirst.com> <20090513084306.5874.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, 13 May 2009, KOSAKI Motohiro wrote:

> > All these expiration modifications do not take into account that a desktop
> > may sit idle for hours while some other things run in the background (like
> > backups at night or updatedb and other maintenance things). This still
> > means that the desktop will be usuable in the morning.
>
> Have you seen this phenomenom?
> I always use linux desktop for development. but I haven't seen it.
> perhaps I have no luck. I really want to know reproduce way.
>
> Please let me know reproduce way.

Run a backup (or rsync) over a few hundred GB.

> > The percentage of file backed pages protected is set via
> > /proc/sys/vm/file_mapped_ratio. This defaults to 20%.
>
> Why do you think typical mapped ratio is less than 20% on desktop machine?

Observation of the typical mapped size of Firefox under KDE.

> key point is access-once vs access-many.

Nothing against it if it works.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
