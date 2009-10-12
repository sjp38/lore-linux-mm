Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0EFAE6B004D
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 05:39:24 -0400 (EDT)
Date: Mon, 12 Oct 2009 17:39:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: make VM_MAX_READAHEAD configurable
Message-ID: <20091012093920.GA2480@localhost>
References: <1255087175-21200-1-git-send-email-ehrhardt@linux.vnet.ibm.com> <1255090830.8802.60.camel@laptop> <20091009122952.GI9228@kernel.dk> <20091009154950.43f01784@mschwide.boeblingen.de.ibm.com> <20091011011006.GA20205@localhost> <4AD2C43D.1080804@linux.vnet.ibm.com> <20091012062317.GA10719@localhost> <4AD2F70C.4010506@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AD2F70C.4010506@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 12, 2009 at 05:29:48PM +0800, Christian Ehrhardt wrote:
> Wu Fengguang wrote:
> > [SNIP]
> >>> May I ask for more details about your performance regression and why
> >>> it is related to readahead size? (we didn't change VM_MAX_READAHEAD..)
> >>>   
> >>>       
> >> Sure, the performance regression appeared when comparing Novell SLES10 
> >> vs. SLES11.
> >> While you are right Wu that the upstream default never changed so far, 
> >> SLES10 had a
> >> patch applied that set 512.
> >>     
> >
> > I see. I'm curious why SLES11 removed that patch. Did it experienced
> > some regressions with the larger readahead size?
> >
> >   
> 
> Only the obvious expected one with very low free/cacheable
> memory and a lot of parallel processes that do sequential I/O.
> The RA size scales up for all of them but 64xMaxRA then
> doesn't fit.
> 
> For example iozone with 64 threads (each on one disk for its own),
> sequential access pattern read with I guess 10 M free for cache
> suffered by ~15% due to trashing.

FYI, I just finished with a patch for dealing with readahead
thrashing.  Will do some tests and post the result :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
