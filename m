Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C8C188D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 20:12:11 -0500 (EST)
Date: Fri, 25 Feb 2011 02:12:05 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
Message-ID: <20110225011205.GK5818@one.firstfloor.org>
References: <1298425922-23630-1-git-send-email-andi@firstfloor.org> <1298425922-23630-9-git-send-email-andi@firstfloor.org> <20110225005155.GH23252@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110225005155.GH23252@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

On Fri, Feb 25, 2011 at 01:51:55AM +0100, Andrea Arcangeli wrote:
> On Tue, Feb 22, 2011 at 05:52:02PM -0800, Andi Kleen wrote:
> > +	"thp_direct_alloc",
> > +	"thp_daemon_alloc",
> > +	"thp_direct_fallback",
> > +	"thp_daemon_alloc_failed",
> 
> I've been wondering if we should do s/daemon/khugepaged/ or

Fine by me.

> s/daemon/collapse/.
> 
> And s/direct/fault/.

Fine for me too.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
