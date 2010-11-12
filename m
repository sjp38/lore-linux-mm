Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E31908D0001
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 11:29:57 -0500 (EST)
Date: Fri, 12 Nov 2010 10:29:52 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH/RFC] MM slub: add a sysfs entry to show the calculated
 number of fallback slabs
In-Reply-To: <1289578964.1972.43.camel@castor.rsk>
Message-ID: <alpine.DEB.2.00.1011121028270.11746@router.home>
References: <1289561309.1972.30.camel@castor.rsk>  <alpine.DEB.2.00.1011120911310.11746@router.home> <1289578964.1972.43.camel@castor.rsk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Pekka Enberg <penberg@kernel.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Nov 2010, Richard Kennedy wrote:

> I know it's not ideal. Of course there already is a counter in
> CONFIG_SLUB_STATS but it only counts the total number of fallback slabs
> issued since boot time.
> I'm not sure if I can reliably decrement a fallback counter when a slab
> get freed. If the size was changed then we could have slabs with several
> different sizes, and off the top of my head I'm not sure if I can
> identify which ones were created as fallback slabs. I don't suppose
> there's a spare flag anywhere.

There are lots of spare flags to be used for SLABs. We just decommissioned
the use of one SLUB_DEBUG. Look at the patchlist and revert that one
giving it a new name like SLUB_FALLBACK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
