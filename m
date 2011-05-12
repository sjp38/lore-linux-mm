Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D7BA26B0028
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:02:08 -0400 (EDT)
Date: Thu, 12 May 2011 11:01:59 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
In-Reply-To: <1305214993.2575.50.camel@mulgrave.site>
Message-ID: <alpine.DEB.2.00.1105121050220.26013@router.home>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>  <1305127773-10570-4-git-send-email-mgorman@suse.de>  <alpine.DEB.2.00.1105120942050.24560@router.home>  <1305213359.2575.46.camel@mulgrave.site>  <alpine.DEB.2.00.1105121024350.26013@router.home>
 <1305214993.2575.50.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, 12 May 2011, James Bottomley wrote:

> > Debian and Ubuntu have been using SLUB for a long time
>
> Only from Squeeze, which has been released for ~3 months.  That doesn't
> qualify as a "long time" in my book.

I am sorry but I have never used a Debian/Ubuntu system in the last 3
years that did not use SLUB. And it was that by default. But then we
usually do not run the "released" Debian version. Typically one runs
testing. Ubuntu is different there we usually run releases. But those
have been SLUB for as long as I remember.

And so far it is rock solid and is widely rolled out throughout our
infrastructure (mostly 2.6.32 kernels).

> but a sample of one doeth not great testing make.
>
> However, since you admit even you see problems, let's concentrate on
> fixing them rather than recriminations?

I do not see problems here with earlier kernels. I only see these on one
testing system with the latest kernels on Ubuntu 11.04.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
