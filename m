Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 65DE46B0062
	for <linux-mm@kvack.org>; Fri, 15 May 2009 14:09:43 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 68C0282C356
	for <linux-mm@kvack.org>; Fri, 15 May 2009 14:22:33 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id SVURa07Bq-pv for <linux-mm@kvack.org>;
	Fri, 15 May 2009 14:22:33 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E6C8082C359
	for <linux-mm@kvack.org>; Fri, 15 May 2009 14:22:24 -0400 (EDT)
Date: Fri, 15 May 2009 14:09:25 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH -mm] vmscan: protect a fraction of file backed mapped
 pages from reclaim
In-Reply-To: <20090515082312.F5B6.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0905151402370.26559@qirst.com>
References: <20090513084306.5874.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0905141612100.15881@qirst.com> <20090515082312.F5B6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, 15 May 2009, KOSAKI Motohiro wrote:

> May I ask detail operation?

Detailed operation? Well no. More of an experience.

Browse the web in the evening. Let the backup run overnight. Try to access
the web in the morning. Pretty unscientific.

> > Observation of the typical mapped size of Firefox under KDE.
>
> My point is, desktop people have very various mapped ratio.
> Do you oppose this?

No of course not. Loads may have different mapped ratios. That is why
there is a /proc/sys/vm tunable in my patch (which is not good as
mentioned in the patch). If Rik's solution works without it great.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
