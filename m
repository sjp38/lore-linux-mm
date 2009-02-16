Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B20126B00C1
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 14:46:33 -0500 (EST)
Message-ID: <4999C199.4090202@cs.helsinki.fi>
Date: Mon, 16 Feb 2009 21:42:17 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch] SLQB slab allocator (try 2)
References: <20090123154653.GA14517@wotan.suse.de> <200902041748.41801.nickpiggin@yahoo.com.au> <20090204152709.GA4799@csn.ul.ie> <200902051459.30064.nickpiggin@yahoo.com.au> <20090216184200.GA31264@csn.ul.ie> <84144f020902161125r59de8a53nfe01566d20ff1658@mail.gmail.com> <20090216194401.GC31264@csn.ul.ie>
In-Reply-To: <20090216194401.GC31264@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
>> There's a follow-up patch from Yanmin which
>> will make a difference for large allocations when page-allocator
>> pass-through is reverted:
>>
>> http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commitdiff;h=79b350ab63458ef1d11747b4f119baea96771a6e
> 
> Is this expected to make a difference to workloads that are not that
> allocator intensive? I doubt it'll make much different to speccpu but
> conceivably it makes a difference to sysbench.

I doubt that too but I fail to see why it's regressing with the revert 
in the first place for speccpu. Maybe it's cache effects, dunno.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
