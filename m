Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 8E8C56B004D
	for <linux-mm@kvack.org>; Sun, 29 Jan 2012 00:17:31 -0500 (EST)
Date: Sun, 29 Jan 2012 13:07:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 6/9] readahead: add /debug/readahead/stats
Message-ID: <20120129050722.GC26244@localhost>
References: <20120127030524.854259561@intel.com>
 <20120127031327.159293683@intel.com>
 <alpine.DEB.2.00.1201271006480.16756@router.home>
 <20120127121551.acd256aa.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120127121551.acd256aa.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Jan 27, 2012 at 12:15:51PM -0800, Andrew Morton wrote:

> > The accounting code will be compiled in by default
> > (CONFIG_READAHEAD_STATS=y), and will remain inactive by default.
> 
> I agree with those choices.  They effectively mean that the stats will
> be a developer-only/debugger-only thing.  So even if the atomic_inc()
> costs are measurable during these develop/debug sessions, is anyone
> likely to care?

Sorry I have changed the default to CONFIG_READAHEAD_STATS=n to avoid
bloating the kernel (and forgot to edit the changelog accordingly).

I'm not sure how many people are going to check the readahead stats.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
