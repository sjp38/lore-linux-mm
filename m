Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 28D8F6B0011
	for <linux-mm@kvack.org>; Fri,  6 May 2011 15:14:46 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <20110506154444.GG6591@suse.de>
References: <20110428171826.GZ4658@suse.de>
	 <1304015436.2598.19.camel@mulgrave.site> <20110428192104.GA4658@suse.de>
	 <1304020767.2598.21.camel@mulgrave.site>
	 <1304025145.2598.24.camel@mulgrave.site>
	 <1304030629.2598.42.camel@mulgrave.site> <20110503091320.GA4542@novell.com>
	 <1304431982.2576.5.camel@mulgrave.site>
	 <1304432553.2576.10.camel@mulgrave.site> <20110506074224.GB6591@suse.de>
	 <20110506154444.GG6591@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 06 May 2011 14:14:37 -0500
Message-ID: <1304709277.12427.29.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Mel Gorman <mgorman@novell.com>, Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Fri, 2011-05-06 at 16:44 +0100, Mel Gorman wrote:
> Colin and James: Did you happen to switch from SLAB to SLUB between
> 2.6.37 and 2.6.38? My own tests were against SLAB which might be why I
> didn't see the problem. Am restarting the tests with SLUB.

Aargh ... I'm an idiot.  I should have thought of SLUB immediately ...
it's been causing oopses since debian switched to it.

So I recompiled the 2.6.38.4 stable kernel with SLAB instead of SLUB and
the problem goes away ... at least from three untar runs on a loaded
box ... of course it could manifest a few ms after I send this email ...

There are material differences, as well: SLAB isn't taking my system
down to very low memory on the untar ... it's keeping about 0.5Gb listed
as free.  SLUB took that to under 100kb, so it could just be that SLAB
isn't wandering as close to the cliff edge?

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
