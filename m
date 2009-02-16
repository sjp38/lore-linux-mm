Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 251436B00BC
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 14:25:38 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so269102fgg.4
        for <linux-mm@kvack.org>; Mon, 16 Feb 2009 11:25:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090216184200.GA31264@csn.ul.ie>
References: <20090123154653.GA14517@wotan.suse.de>
	 <200902041748.41801.nickpiggin@yahoo.com.au>
	 <20090204152709.GA4799@csn.ul.ie>
	 <200902051459.30064.nickpiggin@yahoo.com.au>
	 <20090216184200.GA31264@csn.ul.ie>
Date: Mon, 16 Feb 2009 21:25:35 +0200
Message-ID: <84144f020902161125r59de8a53nfe01566d20ff1658@mail.gmail.com>
Subject: Re: [patch] SLQB slab allocator (try 2)
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Mon, Feb 16, 2009 at 8:42 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> Slightly later than hoped for, but here are the results of the profile
> run between the different slab allocators. It also includes information on
> the performance on SLUB with the allocator pass-thru logic reverted by commit
> http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commitdiff;h=97a4871761e735b6f1acd3bc7c3bac30dae3eab9

Did you just cherry-pick the patch or did you run it with the
topic/slub/perf branch? There's a follow-up patch from Yanmin which
will make a difference for large allocations when page-allocator
pass-through is reverted:

http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commitdiff;h=79b350ab63458ef1d11747b4f119baea96771a6e

                            Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
