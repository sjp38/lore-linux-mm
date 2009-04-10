Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BDE005F0001
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 01:17:12 -0400 (EDT)
Date: Thu, 9 Apr 2009 22:08:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/14] filemap and readahead fixes
Message-Id: <20090409220815.22ef8b21.akpm@linux-foundation.org>
In-Reply-To: <20090410045440.GA8937@localhost>
References: <20090407115039.780820496@intel.com>
	<20090409213643.0e80fdcf.akpm@linux-foundation.org>
	<20090410045440.GA8937@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Mike Waychison <mikew@google.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rohit Seth <rohitseth@google.com>, Edwin <edwintorok@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Apr 2009 12:54:40 +0800 Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Fri, Apr 10, 2009 at 12:36:43PM +0800, Andrew Morton wrote:
> > On Tue, 07 Apr 2009 19:50:39 +0800 Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > This is a set of fixes and cleanups for filemap and readahead.
> > 
> > Unfortunately page_fault-retry-with-nopage_retry.patch got dropped so
> > the first five patches are no longer applicable.  Patch #11 also died.
> > 
> > Can you please respin the remains against current mainline?
> 
> Do you mean rebase them onto linux-next, bypassing Ying Hans' patches?
> 

Those patches are still several akpm-hours ahead in my backlog queue. 
They don't seem to have generated much attention and someone (ie: you)
had substantial comments which haven't been replied to yet.  So I'd
expect another version to be forthcoming.

But I don't mind either way.  I guess the main question here is: do we
see a need to squeeze any of these things into 2.6.30?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
