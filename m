Date: Tue, 10 Jun 2008 08:50:11 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH -mm 17/25] Mlocked Pages are non-reclaimable
Message-ID: <20080610085011.15bd481e@bree.surriel.com>
In-Reply-To: <20080610033130.GK19404@wotan.suse.de>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.522708682@redhat.com>
	<20080606180746.6c2b5288.akpm@linux-foundation.org>
	<20080610033130.GK19404@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jun 2008 05:31:30 +0200
Nick Piggin <npiggin@suse.de> wrote:

> It should definitely be enabled for 32-bit machines, and enabled by default.
> The argument is that 32 bit machines won't have much memory so it won't
> be a problem, but a) it also has to work well on other machines without
> much memory, and b) it is a nightmare to have significant behaviour changes
> like this. For kernel development as well as kernel running.
> 
> If we eventually run out of page flags on 32 bit, then sure this might be
> one we could look at geting rid of. Once the code has proven itself.

Alternatively, we tell the 32 bit people not to compile their kernel
with support for 64 NUMA nodes :)

The number of page flags on 32 bits is (32 - ZONE_SHIFT - NODE_SHIFT)
after Christoph's cleanup and no longer a fixed number.

Does anyone compile a 32 bit kernel with a large (ZONE_SHIFT + NODE_SHIFT)?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
