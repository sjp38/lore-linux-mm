Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 970716B004D
	for <linux-mm@kvack.org>; Sat, 10 Oct 2009 21:10:17 -0400 (EDT)
Date: Sun, 11 Oct 2009 09:10:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: make VM_MAX_READAHEAD configurable
Message-ID: <20091011011006.GA20205@localhost>
References: <1255087175-21200-1-git-send-email-ehrhardt@linux.vnet.ibm.com> <1255090830.8802.60.camel@laptop> <20091009122952.GI9228@kernel.dk> <20091009154950.43f01784@mschwide.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091009154950.43f01784@mschwide.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ehrhardt Christian <ehrhardt@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Martin,

On Fri, Oct 09, 2009 at 09:49:50PM +0800, Martin Schwidefsky wrote:
> On Fri, 9 Oct 2009 14:29:52 +0200
> Jens Axboe <jens.axboe@oracle.com> wrote:
> 
> > On Fri, Oct 09 2009, Peter Zijlstra wrote:
> > > On Fri, 2009-10-09 at 13:19 +0200, Ehrhardt Christian wrote:
> > > > From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
> > > > 
> > > > On one hand the define VM_MAX_READAHEAD in include/linux/mm.h is just a default
> > > > and can be configured per block device queue.
> > > > On the other hand a lot of admins do not use it, therefore it is reasonable to
> > > > set a wise default.
> > > > 
> > > > This path allows to configure the value via Kconfig mechanisms and therefore
> > > > allow the assignment of different defaults dependent on other Kconfig symbols.
> > > > 
> > > > Using this, the patch increases the default max readahead for s390 improving
> > > > sequential throughput in a lot of scenarios with almost no drawbacks (only
> > > > theoretical workloads with a lot concurrent sequential read patterns on a very
> > > > low memory system suffer due to page cache trashing as expected).
[snip]
> 
> The patch from Christian fixes a performance regression in the latest
> distributions for s390. So we would opt for a larger value, 512KB seems
> to be a good one. I have no idea what that will do to the embedded
> space which is why Christian choose to make it configurable. Clearly
> the better solution would be some sort of system control that can be
> modified at runtime. 

May I ask for more details about your performance regression and why
it is related to readahead size? (we didn't change VM_MAX_READAHEAD..)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
