Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A296E6B01F2
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 05:27:58 -0400 (EDT)
Date: Thu, 19 Aug 2010 10:25:36 +0100
From: Chris Webb <chris@arachsys.com>
Subject: Re: Over-eager swapping
Message-ID: <20100819092536.GH2370@arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100819051339.GH28417@balbir.in.ibm.com>
 <20100818164539.GG28417@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh <balbir@linux.vnet.ibm.com> writes:

> Can you give an idea of what the meminfo inside the guest looks like.

Sorry for the slow reply here. Unfortunately not, as these guests are run on
behalf of customers. They install them with operating systems of their
choice, and run them on our service.

> Have you looked at
> http://kerneltrap.org/mailarchive/linux-kernel/2010/6/8/4580772

Yes, I've been watching this discussions with interest. Our application is
one where we have little to no control over what goes on inside the guests,
but these sorts of things definitely make sense where the two are under the
same administrative control.

> Do we have reason to believe the problem can be solved entirely in the
> host?

It's not clear to me why this should be difficult, given that the total size
of vm allocated to guests (and system processes) is always strictly less
than the total amount of RAM available in the host. I do understand that it
won't allow for as impressive overcommit (except by ksm) or be as efficient,
because file-backed guest pages won't get evicted by pressure in the host as
they are indistinguishable from anonymous pages.

After all, a solution that isn't ideal, but does work, is to turn off swap
completely! This is what we've been doing to date. The only problem with
this is that we can't dip into swap in an emergency if there's no swap there
at all.

Best wishes,

Chris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
