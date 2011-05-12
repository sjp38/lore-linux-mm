Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8BFA96B0023
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:00:27 -0400 (EDT)
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <20110512154649.GB4559@redhat.com>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>
	 <1305127773-10570-4-git-send-email-mgorman@suse.de>
	 <alpine.DEB.2.00.1105120942050.24560@router.home>
	 <1305213359.2575.46.camel@mulgrave.site>
	 <alpine.DEB.2.00.1105121024350.26013@router.home>
	 <1305214993.2575.50.camel@mulgrave.site> <20110512154649.GB4559@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 12 May 2011 11:00:23 -0500
Message-ID: <1305216023.2575.54.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, 2011-05-12 at 11:46 -0400, Dave Jones wrote:
> On Thu, May 12, 2011 at 10:43:13AM -0500, James Bottomley wrote:
> 
>  > As I said above, no released fedora version uses SLUB.  It's only just
>  > been enabled for the unreleased FC15; I'm testing a beta copy.
> 
> James, this isn't true.
> 
> $ grep SLUB /boot/config-2.6.35.12-88.fc14.x86_64 
> CONFIG_SLUB_DEBUG=y
> CONFIG_SLUB=y
> 
> (That's the oldest release I have right now, but it's been enabled even
> before that release).

OK, I concede the point ... I haven't actually kept any of my FC
machines current for a while.

However, the fact remains that this seems to be a slub problem and it
needs fixing.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
