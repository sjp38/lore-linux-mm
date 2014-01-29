Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id DFE886B0037
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 01:43:56 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so1382450pad.8
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 22:43:56 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [143.182.124.37])
        by mx.google.com with ESMTP id if4si1299423pbc.346.2014.01.28.22.43.55
        for <linux-mm@kvack.org>;
        Tue, 28 Jan 2014 22:43:55 -0800 (PST)
Date: Wed, 29 Jan 2014 14:43:50 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: slub: fix page->_count corruption (again)
Message-ID: <20140129064350.GA20252@localhost>
References: <20140128231722.E7387E6B@viggo.jf.intel.com>
 <20140128152956.d5659f56ae279856731a1ac5@linux-foundation.org>
 <52E842CF.7090102@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52E842CF.7090102@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, pshelar@nicira.com

On Tue, Jan 28, 2014 at 03:52:47PM -0800, Dave Hansen wrote:
> On 01/28/2014 03:29 PM, Andrew Morton wrote:
> > On Tue, 28 Jan 2014 15:17:22 -0800 Dave Hansen <dave@sr71.net> wrote:
> > This code is borderline insane.
> 
> No argument here.
> 
> > Yes, struct page is special and it's worth spending time and doing
> > weird things to optimise it.  But sheesh.
> > 
> > An alternative is to make that cmpxchg quietly go away.  Is it more
> > trouble than it is worth?
> 
> It has measurable performance benefits, and the benefits go up as the
> cost of en/disabling interrupts goes up (like if it takes you a hypercall).
> 
> Fengguang, could you run a set of tests for the top patch in this branch
> to see if we'd be giving much up by axing the code?
> 
> 	https://github.com/hansendc/linux/tree/slub-nocmpxchg-for-Fengguang-20140128

Sure, I've queued tests for the branch. Will report back after 1-2
days.

Thanks,
Fengguang

> I was talking with one of the distros about turning it off as well.
> They mentioned that they saw a few performance regressions when it was
> turned off.  I'll share details when I get them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
