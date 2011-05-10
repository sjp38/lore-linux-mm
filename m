Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 88EAE90010E
	for <linux-mm@kvack.org>; Tue, 10 May 2011 06:33:15 -0400 (EDT)
Received: by vxk20 with SMTP id 20so9921012vxk.14
        for <linux-mm@kvack.org>; Tue, 10 May 2011 03:33:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110510102141.GA4149@novell.com>
References: <20110428192104.GA4658@suse.de>
	<1304020767.2598.21.camel@mulgrave.site>
	<1304025145.2598.24.camel@mulgrave.site>
	<1304030629.2598.42.camel@mulgrave.site>
	<20110503091320.GA4542@novell.com>
	<1304431982.2576.5.camel@mulgrave.site>
	<1304432553.2576.10.camel@mulgrave.site>
	<20110506074224.GB6591@suse.de>
	<20110506080728.GC6591@suse.de>
	<1304964980.4865.53.camel@mulgrave.site>
	<20110510102141.GA4149@novell.com>
Date: Tue, 10 May 2011 13:33:11 +0300
Message-ID: <BANLkTi=JwoHtTky=mF5fkhS23mm_dJu4og@mail.gmail.com>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback related.
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@novell.com>
Cc: James Bottomley <James.Bottomley@suse.de>, Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, Christoph Lameter <cl@linux.com>

On Tue, May 10, 2011 at 1:21 PM, Mel Gorman <mgorman@novell.com> wrote:
> It goes on. A number of filesystem and network paths are being hit
> with high-order allocs. i915 was a red herring, it's present but not
> in massive numbers. The filesystem, network and mempool allocations
> are likely to be kicking kswapd awake frequently and hurting overall
> system performance as a result.
>
> I really would like to hear if the fix makes a big difference or
> if we need to consider forcing SLUB high-order allocations bailing
> at the first sign of trouble (e.g. by masking out __GFP_WAIT in
> allocate_slab). Even with the fix applied, kswapd might be waking up
> less but processes will still be getting stalled in direct compaction
> and direct reclaim so it would still be jittery.

Yes, sounds reasonable to me.

                         Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
