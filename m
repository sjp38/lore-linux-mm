Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 695FC5F0001
	for <linux-mm@kvack.org>; Mon, 13 Apr 2009 09:18:51 -0400 (EDT)
Date: Mon, 13 Apr 2009 21:18:42 +0800
From: Wu Fengguang <wfg@linux.intel.com>
Subject: Re: [PATCH] [0/16] POISON: Intro
Message-ID: <20090413131842.GA8640@localhost>
References: <20090407509.382219156@firstfloor.org> <20090407224709.742376ff.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090407224709.742376ff.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 07, 2009 at 10:47:09PM -0700, Andrew Morton wrote:
> On Tue,  7 Apr 2009 17:09:56 +0200 (CEST) Andi Kleen <andi@firstfloor.org> wrote:
> 
> > Upcoming Intel CPUs have support for recovering from some memory errors. This
> > requires the OS to declare a page "poisoned", kill the processes associated
> > with it and avoid using it in the future. This patchkit implements
> > the necessary infrastructure in the VM.
> 
> Seems that this feature is crying out for a testing framework (perhaps
> it already has one?).  A simplistic approach would be
> 
> 	echo some-pfn > /proc/bad-pfn-goes-here

How about reusing the /proc/kpageflags interface? i.e. make it writable.

It may sound crazy and way too _hacky_, but it is possible to
attach actions to the state transition of some page flags ;)

PG_poison      0 => 1: call memory_failure()

PG_active      1 => 0: move page into inactive lru
PG_unevictable 1 => 0: move page out of unevictable lru
PG_swapcache   1 => 0: remove page from swap cache
PG_lru         1 => 0: reclaim page

Thanks,
Fengguang

> A slightly more sophisticated version might do the deed from within a
> timer interrupt, just to get a bit more coverage.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
