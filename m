Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 21C6E8D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 16:24:08 -0500 (EST)
Date: Wed, 9 Feb 2011 22:24:04 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/5] fix up /proc/$pid/smaps to not split huge pages
Message-ID: <20110209212404.GR3347@random.random>
References: <20110209195406.B9F23C9F@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110209195406.B9F23C9F@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>

On Wed, Feb 09, 2011 at 11:54:06AM -0800, Dave Hansen wrote:
> Andrea, after playing with this for a week or two, I'm quite a bit
> more confident that it's not causing much harm.  Seems a fairly
> low-risk feature.  Could we stick these somewhere so they'll at
> least hit linux-next for the 2.6.40 cycle perhaps?

I think they're good to go in mmotm already and to be merged ASAP.

The only minor issue I have is the increment, to become per-cpu. Are
we going to change its location then or it's still read through sysfs?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
