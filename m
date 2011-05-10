Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6416290010C
	for <linux-mm@kvack.org>; Tue, 10 May 2011 10:01:09 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <20110510102141.GA4149@novell.com>
References: <20110428192104.GA4658@suse.de>
	 <1304020767.2598.21.camel@mulgrave.site>
	 <1304025145.2598.24.camel@mulgrave.site>
	 <1304030629.2598.42.camel@mulgrave.site> <20110503091320.GA4542@novell.com>
	 <1304431982.2576.5.camel@mulgrave.site>
	 <1304432553.2576.10.camel@mulgrave.site> <20110506074224.GB6591@suse.de>
	 <20110506080728.GC6591@suse.de> <1304964980.4865.53.camel@mulgrave.site>
	 <20110510102141.GA4149@novell.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 10 May 2011 09:01:04 -0500
Message-ID: <1305036064.6737.8.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@novell.com>
Cc: Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Tue, 2011-05-10 at 11:21 +0100, Mel Gorman wrote:
> I really would like to hear if the fix makes a big difference or
> if we need to consider forcing SLUB high-order allocations bailing
> at the first sign of trouble (e.g. by masking out __GFP_WAIT in
> allocate_slab). Even with the fix applied, kswapd might be waking up
> less but processes will still be getting stalled in direct compaction
> and direct reclaim so it would still be jittery.

"the fix" being this

https://lkml.org/lkml/2011/3/5/121

In addition to your GFP_KSWAPD one?

OK, will retry with that.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
