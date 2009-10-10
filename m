Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3BCA76B004D
	for <linux-mm@kvack.org>; Sat, 10 Oct 2009 13:41:59 -0400 (EDT)
Date: Sat, 10 Oct 2009 10:41:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: make VM_MAX_READAHEAD configurable
Message-Id: <20091010104111.547d8abe.akpm@linux-foundation.org>
In-Reply-To: <20091010124042.GA9179@localhost>
References: <1255087175-21200-1-git-send-email-ehrhardt@linux.vnet.ibm.com>
	<1255090830.8802.60.camel@laptop>
	<20091009122952.GI9228@kernel.dk>
	<20091009143124.1241a6bc.akpm@linux-foundation.org>
	<20091010105333.GR9228@kernel.dk>
	<20091010124042.GA9179@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ehrhardt Christian <ehrhardt@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sat, 10 Oct 2009 20:40:42 +0800 Wu Fengguang <fengguang.wu@intel.com> wrote:

> > not sure if it attempts to do anything based on how quickly
> > the device is doing IO. Wu?
> 
> Not for current kernel.  But in fact it's possible to estimate the
> read speed for each individual sequential stream, and possibly drop
> some hint to the IO scheduler: someone will block on this IO after 3
> seconds. But it may not deserve the complexity.

Well, we have a test case.  Would any of your design proposals address
the performance problem which motivated the s390 guys to propose this
patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
