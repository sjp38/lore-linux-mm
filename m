Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 242E66B0026
	for <linux-mm@kvack.org>; Fri, 13 May 2011 14:23:41 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Possible sandybridge livelock issue
References: <1305303156.2611.51.camel@mulgrave.site>
	<m262pezhfe.fsf@firstfloor.org>
	<alpine.DEB.2.00.1105131207020.24193@router.home>
Date: Fri, 13 May 2011 11:23:14 -0700
In-Reply-To: <alpine.DEB.2.00.1105131207020.24193@router.home> (Christoph
	Lameter's message of "Fri, 13 May 2011 12:08:06 -0500 (CDT)")
Message-ID: <m21v02zch9.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, x86@kernel.org, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Christoph Lameter <cl@linux.com> writes:

> On Fri, 13 May 2011, Andi Kleen wrote:
>
>> Turbo mode just makes the CPU faster, but it should not change
>> the scheduler decisions.
>
> I also have similar issues with Sandybridge on Ubuntu 11.04 and kernels
> 2.6.38 as well as 2.6.39 (standard ubuntu kernel configs).

It still doesn't make a lot of sense to blame the CPU for this.
This is just not the level how CPU problems would likely appear.

Can you figure out better what the kswapd is doing?

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
