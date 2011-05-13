Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 141826B0012
	for <linux-mm@kvack.org>; Fri, 13 May 2011 13:08:10 -0400 (EDT)
Date: Fri, 13 May 2011 12:08:06 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Possible sandybridge livelock issue
In-Reply-To: <m262pezhfe.fsf@firstfloor.org>
Message-ID: <alpine.DEB.2.00.1105131207020.24193@router.home>
References: <1305303156.2611.51.camel@mulgrave.site> <m262pezhfe.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, x86@kernel.org, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

On Fri, 13 May 2011, Andi Kleen wrote:

> Turbo mode just makes the CPU faster, but it should not change
> the scheduler decisions.

I also have similar issues with Sandybridge on Ubuntu 11.04 and kernels
2.6.38 as well as 2.6.39 (standard ubuntu kernel configs).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
