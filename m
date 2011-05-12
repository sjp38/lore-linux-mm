Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C9E93900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 14:37:53 -0400 (EDT)
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <1305215742.27848.40.camel@jaguar>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>
	 <1305127773-10570-4-git-send-email-mgorman@suse.de>
	 <alpine.DEB.2.00.1105120942050.24560@router.home>
	 <1305213359.2575.46.camel@mulgrave.site>
	 <alpine.DEB.2.00.1105121024350.26013@router.home>
	 <1305214993.2575.50.camel@mulgrave.site> <1305215742.27848.40.camel@jaguar>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 12 May 2011 13:37:47 -0500
Message-ID: <1305225467.2575.66.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, 2011-05-12 at 18:55 +0300, Pekka Enberg wrote:
> On Thu, 2011-05-12 at 10:43 -0500, James Bottomley wrote:
> > However, since you admit even you see problems, let's concentrate on
> > fixing them rather than recriminations?
> 
> Yes, please. So does dropping max_order to 1 help?
> PAGE_ALLOC_COSTLY_ORDER is set to 3 in 2.6.39-rc7.

Just booting with max_slab_order=1 (and none of the other patches
applied) I can still get the machine to go into kswapd at 99%, so it
doesn't seem to make much of a difference.

Do you want me to try with the other two patches and max_slab_order=1?

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
